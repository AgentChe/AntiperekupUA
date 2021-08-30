//
//  ReportScreenViewModel.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 05.08.2021.
//

import RxSwift
import RxCocoa

final class ReportScreenViewModel {
    typealias DataSource = (String, [ReportTableItem])
    typealias Elements = [ReportTableItem]
    
    private lazy var paygateService = PurchaseManagerCore()
    private lazy var reportService = ReportManagerCore()
    private let searchValue: ReportSearchValue
    
    init(searchValue: ReportSearchValue) {
        self.searchValue = searchValue
    }
}

extension ReportScreenViewModel {
    struct Input {
        let inputValue: Signal<ReportSearchValue>
        let selectedElement: Signal<ReportTableItem>
    }
    
    struct Output {
        let elements: Driver<[DataSource]>
        let showChangeAlert: Signal<ReportValueWithActionModel>
        let showPaygate: Signal<Void>
    }
    
    func configure(input: Input) -> Output {
    
        let isActiveSubscription = paygateService.isActiveSubscription()
            .asObservable()
            .share(replay: 1)
        
        let searchValue = Observable.just(searchValue)
        
        let baseData = makeBaseData(searchValue: searchValue, inputValue: input.inputValue)
            .share(replay: 1, scope: .forever)
        
        let mainAndHistory = makeMainAndHistorySection(baseData: baseData)
            .share(replay: 1)
        
        let elements = Observable
            .combineLatest([
                makeBaseSection(baseData: baseData),
                mainAndHistory.map { $0.main },
                mainAndHistory.map { $0.history },
                makeWantedSection(baseData: baseData),
                makeInterpolSection(baseData: baseData),
                makePhotosSection(baseData: baseData),
                makeMTSBUSection(),
                makeCommentsSection(baseData: baseData),
                makeLockedSection(baseData: baseData, isActiveSubscription: isActiveSubscription)
            ]) { elements -> [DataSource] in
                return elements.map { ("", $0) }
            }
            .asDriver(onErrorJustReturn: [])
        
        let showChangeAlert = input.selectedElement
            .asObservable()
            .compactMap { element -> ReportValueWithActionModel? in
                guard case let .valueWithAction(model) = element, model.action != .none else { return nil }
                
                return model
            }
            .asSignal(onErrorSignalWith: .empty())
        
        let showPaygate = input.selectedElement
            .asObservable()
            .compactMap { element -> Void? in
                guard case .locked = element else { return nil }
                return ()
            }
            .asSignal(onErrorSignalWith: .empty())
        
        return Output(
            elements: elements,
            showChangeAlert: showChangeAlert,
            showPaygate: showPaygate
        )
    }
    
    
}

// MARK: Private
private extension ReportScreenViewModel {
    
    func makeBaseData(searchValue: Observable<ReportSearchValue>, inputValue: Signal<ReportSearchValue>) -> Observable<BaseData> {
        let baseData = searchValue
            .flatMapLatest { [reportService] value -> Observable<BaseData> in
                switch value {
                case let .vin(value):
                    return reportService
                        .getRegNumberByVin(vin: value)
                        .asObservable()
                        .map { model in
                            let regNumber = model?.regNumber ?? ""
                            
                            return BaseData(
                                vin: value,
                                regNumber: regNumber,
                                isEditableVin: false,
                                isEditableNumber: regNumber.isEmpty || regNumber.contains("_")
                            )
                        }
                case let .regNumber(value):
                    // TODO: После реализации WebView поправить конфигурацию данных
                    return .just(BaseData(regNumber: value, isEditableVin: true, isEditableNumber: false))
                case let .technicalPassport(series, number):
                    return reportService
                        .getVinAndRegNumberByRegDoc(series: series, number: number)
                        .asObservable()
                        .map { model in
                            let vin = model?.vin ?? ""
                            let regNumber = model?.regNumber ?? ""
                            return BaseData(
                                vin: vin,
                                regNumber: regNumber,
                                technicalPassport: "\(series)\(number)",
                                isEditableVin: vin.isEmpty || vin.contains("_"),
                                isEditableNumber: regNumber.isEmpty || regNumber.contains("_")
                            )
                        }
                }
            }
        
        return Observable<Action>
            .merge(
                baseData.map { .baseData($0) },
                inputValue.asObservable().map { .input($0) }
            )
            .scan(nil, accumulator: { old, action -> BaseData? in
                switch action {
                case let .baseData(data):
                    return data
                case let .input(type):
                    guard var current = old else { return nil }
                    switch type {
                    case let .vin(vin):
                        current.change(vin: vin)
                    case let .regNumber(number):
                        current.change(regNumber: number)
                    case let .technicalPassport(series, number):
                        current.change(passport: "\(series)\(number)")
                    }

                    return current
                }
            })
            .compactMap { $0 }
    }
    
    func makeBaseSection(baseData: Observable<BaseData>) -> Observable<Elements> {
        let headerTitle = "wanted_title".localized
        
        return baseData
            .map { model -> Elements in
                let regNumber = ReportValueWithActionModel(
                    value: model.regNumber,
                    action: model.regNumber.isEmpty ? .add : (model.regNumber.contains("_") || model.isEditableNumber) ? .change : .none,
                    fieldType: .regNumber
                )
                
                let vin = ReportValueWithActionModel(
                    value: model.vin,
                    action: model.vin.isEmpty ? .add : (model.vin.contains("_") || model.isEditableVin) ? .change : .none,
                    fieldType: .vin
                )
                
                let technicalPassport = ReportValueWithActionModel(
                    value: model.technicalPassport,
                    action: model.technicalPassport.isEmpty ? .add : model.technicalPassport.contains("_") ? .change : .none,
                    fieldType: .technicalPassport
                )
                
                let items: [ReportTableItem] = [
                    .header(.init(title: headerTitle, state: .empty)),
                    .valueWithAction(regNumber),
                    .valueWithAction(vin),
                    .valueWithAction(technicalPassport)
                ]
                
                return items
            }
            .startWith([.header(.init(title: headerTitle, state: .empty)), .loader])
    }
    
    func makeMainAndHistorySection(baseData: Observable<BaseData>) -> Observable<(main: Elements, history: Elements)> {
        let mainTitle = "main_information".localized
        let historyTitle = "registration_history".localized
        
        let loadingSections = (
            main: [ReportTableItem.header(.init(title: mainTitle, state: .empty)), .loader],
            history: [ReportTableItem.header(.init(title: historyTitle, state: .empty)), .loader]
        )
        
        return baseData
            .distinctUntilChanged { $0.regNumber == $1.regNumber }
            .withUnretained(self)
            .flatMapLatest { base, data -> Observable<(main: Elements, history: Elements)> in
                
                guard data.isValidNumber else {
                    let text = String(format: "required_empty_data_warning".localized, "gos_number_type".localized)
                    let mainItems: [ReportTableItem] = [
                        .header(.init(title: mainTitle, state: .error)),
                        .text(text)
                    ]
                    
                    let historyItems: [ReportTableItem] = [
                        .header(.init(title: historyTitle, state: .error)),
                        .text(text)
                    ]
                    
                    let additional = base.additionalActionItems(baseData: data, for: .regNumber, .technicalPassport)
                    
                    return .just((main: mainItems + additional, history: historyItems + additional))
                }
                
                return base.reportService
                    .getGovData(regNumber: data.regNumber)
                    .asObservable()
                    .withUnretained(base)
                    .map { base, model -> (main: Elements, history: Elements) in
                        guard let model = model, model.result else {
                            return (base.errorSection(headerText: mainTitle, message: model?.errorMessage), base.errorSection(headerText: historyTitle, message: model?.errorMessage))
                        }
                        
                        let main: [ReportTableItem] = model.vehicle
                            .map { vehicle in
                                [
                                    .header(.init(title: mainTitle, state: .success)),
                                    vehicle.logo.map { .logo($0) },
                                    .value(.init(title: "gov_data_regnumber".localized, value: vehicle.regNumber)),
                                    .value(.init(title: "gov_data_vin".localized, value: vehicle.vin)),
                                    .value(.init(title: "gov_data_brand".localized, value: vehicle.brand)),
                                    .value(.init(title: "gov_data_model".localized, value: vehicle.model)),
                                    .value(.init(title: "gov_data_color".localized, value: vehicle.color)),
                                    .value(.init(title: "gov_data_body".localized, value: vehicle.body)),
                                    .value(.init(title: "gov_data_purpose".localized, value: vehicle.purpose)),
                                    .value(.init(title: "gov_data_kind".localized, value: vehicle.kind)),
                                    .value(.init(title: "gov_data_capacity".localized, value: vehicle.capacity)),
                                    .value(.init(title: "gov_data_year".localized, value: vehicle.year)),
                                    .value(.init(title: "gov_data_fuel".localized, value: vehicle.fuel)),
                                    .value(.init(title: "gov_data_own_weight".localized, value: vehicle.ownWeight)),
                                    .value(.init(title: "gov_data_total_weight".localized, value: vehicle.totalWeight))
                                ].compactMap { $0 }
                            } ?? [
                                .header(.init(title: mainTitle, state: .error)),
                                .iconWithText(.init(text: "no_gov_data_information_found".localized, iconType: .error))
                            ]
                        
                        var initialHistory: [ReportTableItem] {
                            let isEmpty = model.records.isEmpty
                            let text = isEmpty ? "no_gov_data_information_found".localized : String(format: "records".localized, model.records.count)
                            
                            let result: ReportTableItem = .iconWithText(.init(text: text, iconType: isEmpty ? .error : .success))
                            let header: ReportTableItem = .header(.init(title: historyTitle, state: isEmpty ? .error : .success))
                            
                            return [header, result]
                        }
                        
                        let history: [ReportTableItem] = model.records
                            .enumerated()
                            .reduce(into: initialHistory) {
                                $0.append(.value(.init(title: "gov_data_date".localized, value: $1.element.date)))
                                $0.append(.value(.init(title: "gov_data_person".localized, value: $1.element.person)))
                                $0.append(.value(.init(title: "gov_data_regnumber".localized, value: $1.element.regNumber)))
                                $0.append(.value(.init(title: "gov_data_vin".localized, value: $1.element.vin)))
                                $0.append(.value(.init(title: "gov_data_brand".localized, value: $1.element.brand)))
                                $0.append(.value(.init(title: "gov_data_model".localized, value: $1.element.model)))
                                $0.append(.value(.init(title: "gov_data_year".localized, value: $1.element.year)))
                                $0.append(.value(.init(title: "gov_data_color".localized, value: $1.element.color)))
                                $0.append(.value(.init(title: "gov_data_department".localized, value: $1.element.departament)))
                                $0.append(.value(.init(title: "gov_data_department_code".localized, value: $1.element.departamentCode)))
                                $0.append(.value(.init(title: "gov_data_operation_code".localized, value: $1.element.operationCode)))
                                $0.append(.value(.init(title: "gov_data_operation_name".localized, value: $1.element.operationName)))
                                $0.append(.value(.init(title: "gov_data_reg_addr_koatuu".localized, value: $1.element.regAddrKoatuu)))
                                if $1.offset < model.records.count - 1 {
                                    $0.append(.separator)
                                }
                            }
                        
                        return (main: main, history: history)
                    }
                    .startWith(loadingSections)
            }
            .startWith(loadingSections)
    }
    
    func makeWantedSection(baseData: Observable<BaseData>) -> Observable<Elements> {
        let headerTitle = "wanted_title".localized
        
        return baseData
            .distinctUntilChanged { $0.vin == $1.vin && $0.regNumber == $1.regNumber }
            .withUnretained(self)
            .flatMapLatest { base, data -> Observable<Elements> in
                
                let additional = base.additionalActionItems(baseData: data, for: .regNumber, .vin, .technicalPassport)
                
                guard data.isValidNumber || data.isValidVin else {
                    let type = data.isValidNumber ? "vin_code_type".localized : "gos_number_type".localized
                    let text = String(format: "required_empty_data_warning".localized, type)
                    let items: [ReportTableItem] = [.header(.init(title: headerTitle, state: .error)), .text(text)]
                    return .just(items + additional)
                }
                
                let regNumber = data.isValidNumber ? data.regNumber : ""
                let vin = data.isValidVin ? data.vin : ""
                
                return base.reportService
                    .getWanted(regNumber: regNumber, vin: vin)
                    .asObservable()
                    .withUnretained(self)
                    .map { base, model -> Elements in
                        guard let model = model, model.result else {
                            return base.errorSection(headerText: headerTitle, message: model?.errorMessage)
                        }
                        
                        guard !model.wanted.isEmpty else {
                            let text = "no_wanted_information_found".localized
                            return [
                                .header(.init(title: headerTitle, state: .success)),
                                .iconWithText(.init(text: text, iconType : .success))
                            ]
                        }
                        
                        let recordCount = ReportTableItem.iconWithText(.init(text: String(format: "records_wanted".localized, model.wanted.count), iconType: .error))
                        
                        let items: [ReportTableItem] = model.wanted
                            .enumerated()
                            .reduce(into: [.header(.init(title: headerTitle, state: .error)), recordCount]) {
                                $0.append(.value(.init(title: "wanted_ovd".localized, value: $1.element.ovd)))
                                $0.append(.value(.init(title: "wanted_brand".localized, value: $1.element.brand)))
                                $0.append(.value(.init(title: "wanted_color".localized, value: $1.element.color)))
                                $0.append(.value(.init(title: "wanted_vehicle_number".localized, value: $1.element.vehicleNumber)))
                                $0.append(.value(.init(title: "wanted_body_number".localized, value: $1.element.bodyNumber)))
                                $0.append(.value(.init(title: "wanted_chassis_number".localized, value: $1.element.chassisNumber)))
                                $0.append(.value(.init(title: "wanted_engine_number".localized, value: $1.element.engineNumber)))
                                $0.append(.value(.init(title: "wanted_theft_date".localized, value: $1.element.theftDate)))
                                $0.append(.value(.init(title: "wanted_insert_date".localized, value: $1.element.insertDate)))
                                if $1.offset < model.wanted.count - 1 {
                                    $0.append(.separator)
                                }
                            }
                        
                        return items + additional
                    }
                    .startWith([.header(.init(title: headerTitle, state: .empty)), .loader])
            }
            .startWith([.header(.init(title: headerTitle, state: .empty)), .loader])
    }
    
    func makeInterpolSection(baseData: Observable<BaseData>) -> Observable<Elements> {
        let headerTitle = "interpol_title".localized
        
        return baseData
            .distinctUntilChanged { $0.vin == $1.vin }
            .withUnretained(self)
            .flatMapLatest { base, data -> Observable<Elements> in
                
                guard data.isValidVin else {
                    let text = String(format: "required_empty_data_warning".localized, "vin_code_type".localized)
                    
                    let items: [ReportTableItem] = [
                        .header(.init(title: headerTitle, state: .error)),
                        .text(text)
                    ]
                    
                    let additional = base.additionalActionItems(baseData: data, for: .vin, .technicalPassport)
                    return .just(items + additional)
                }
                
                return base.reportService
                    .getInterpol(vin: data.vin)
                    .asObservable()
                    .withUnretained(self)
                    .map { base, model -> Elements in
                        guard let model = model, model.result else {
                            return base.errorSection(headerText: headerTitle, message: model?.errorMessage)
                        }
                        
                        guard !model.interpol.isEmpty else {
                            let items: [ReportTableItem] = [
                                .header(.init(title: headerTitle, state: .success)),
                                .iconWithText(.init(text: "no_interpol_information_found".localized, iconType: .success))
                            ]
                            return items
                        }
                        
                        let recordCount = ReportTableItem.iconWithText(.init(text: String(format: "records_wanted".localized, model.interpol.count), iconType: .error))
                        
                        let items: [ReportTableItem] = model.interpol
                            .enumerated()
                            .reduce(into: [.header(.init(title: headerTitle, state: .error)), recordCount]) {
                                $0.append(.value(.init(title: "interpol_vin".localized, value: $1.element.vin)))
                                $0.append(.value(.init(title: "interpol_number".localized, value: $1.element.number)))
                                $0.append(.value(.init(title: "interpol_date_added".localized, value: $1.element.addedDate)))
                                $0.append(.value(.init(title: "interpol_date_theft".localized, value: $1.element.theftDate)))
                                $0.append(.value(.init(title: "interpol_engine".localized, value: $1.element.engine)))
                                $0.append(.value(.init(title: "interpol_type".localized, value: $1.element.type)))
                                $0.append(.value(.init(title: "interpol_make_model".localized, value: $1.element.makeModel)))
                                if $1.offset < model.interpol.count - 1 {
                                    $0.append(.separator)
                                }
                            }
                        
                        return items
                    }
                    .startWith([.header(.init(title: headerTitle, state: .empty)), .loader])
            }
            .startWith([.header(.init(title: headerTitle, state: .empty)), .loader])
    }
    
    func makePhotosSection(baseData: Observable<BaseData>) -> Observable<Elements> {
        let headerTitle = "photos_title".localized
        
        return baseData
            .distinctUntilChanged { $0.regNumber == $1.regNumber }
            .withUnretained(self)
            .flatMapLatest { base, data -> Observable<Elements> in
                
                guard data.isValidNumber else {
                    let text = String(format: "required_empty_data_warning".localized, "gos_number_type".localized)
                    
                    let items: [ReportTableItem] = [
                        .header(.init(title: headerTitle, state: .error)),
                        .text(text)
                    ]
                    
                    let additional = base.additionalActionItems(baseData: data, for: .regNumber, .technicalPassport)
                    
                    return .just(items + additional)
                }
                
                return base.reportService
                    .getPhotos(regNumber: data.regNumber)
                    .asObservable()
                    .withUnretained(self)
                    .map { base, model -> Elements in
                        guard let model = model, model.result else {
                            return base.errorSection(headerText: headerTitle, message: model?.errorMessage)
                        }
                        
                        var initialItems: [ReportTableItem] {
                            let isEmpty = model.photos.isEmpty
                            let text = isEmpty ? "no_photos_information_found".localized : String(format: "photos".localized, model.photos.count)
                            
                            let result: ReportTableItem = .iconWithText(.init(text: text, iconType: isEmpty ? .error : .success))
                            let header: ReportTableItem = .header(.init(title: headerTitle, state: isEmpty ? .error : .success))
                            
                            return [header, result]
                        }
                        
                        let items: [ReportTableItem] = model.photos
                            .enumerated()
                            .reduce(into: initialItems) {
                                $0.append(.value(.init(title: "photos_make".localized, value: $1.element.make)))
                                $0.append(.value(.init(title: "photos_model".localized, value: $1.element.model)))
                                $0.append(.value(.init(title: "photos_date".localized, value: $1.element.date)))
                                if let url = $1.element.url {
                                    $0.append(.photo(url))
                                }
                                
                                if $1.offset < model.photos.count - 1 {
                                    $0.append(.separator)
                                }
                        }
                        
                        
                        return items
                    }
                    .startWith([.header(.init(title: headerTitle, state: .empty)), .loader])
            }
            .startWith([.header(.init(title: headerTitle, state: .empty)), .loader])
    }
    
    func makeMTSBUSection() -> Observable<Elements> {
        // TODO: Реализовать после реализации WebView
        let headerTitle = "mtsbu_title".localized
        
        return .just([.header(.init(title: headerTitle, state: .empty)), .text("TODO: Реализовать после реализации WebView")])
    }
    
    func makeCommentsSection(baseData: Observable<BaseData>) -> Observable<Elements> {
        let headerTitle = "user_comments".localized
        
        return baseData
            .distinctUntilChanged { $0.vin == $1.vin && $0.regNumber == $1.regNumber }
            .withUnretained(self)
            .flatMapLatest { base, data -> Observable<Elements> in
                
                guard data.isValidNumber || data.isValidVin else {
                    let type = data.isValidNumber ? "vin_code_type".localized : "gos_number_type".localized
                    let text = String(format: "required_empty_data_warning".localized, type)
                    let items: [ReportTableItem] = [.header(.init(title: headerTitle, state: .error)), .text(text)]
                    
                    let additional = base.additionalActionItems(baseData: data, for: .regNumber, .vin, .technicalPassport)
                    return .just(items + additional)
                }
                
                let regNumber = data.isValidNumber ? data.regNumber : ""
                let vin = data.isValidVin ? data.vin : ""
                
                return base.reportService
                    .getComments(regNumber: regNumber, vin: vin)
                    .asObservable()
                    .withUnretained(self)
                    .map { base, model -> Elements in
                        guard let model = model, model.result else {
                            return base.errorSection(headerText: headerTitle, message: model?.errorMessage)
                        }
                        
                        guard !model.comments.isEmpty else {
                            let text = "user_comments_not_found".localized
                            let items: [ReportTableItem] = [
                                .header(.init(title: headerTitle, state: .error)),
                                .iconWithText(.init(text: text, iconType : .error))
                            ]
                            
                            return items
                        }
                        
                        let initialItems: [ReportTableItem] = [
                            .header(.init(title: headerTitle, state: .success)),
                            .iconWithText(.init(text: "user_comments_found".localized, iconType: .success))
                        ]
                        
                        let items: [ReportTableItem] = model.comments
                            .enumerated()
                            .reduce(into: initialItems) {
                                $0.append(.complain(id: $1.element.id))
                                $0.append(.value(.init(title: "comment_vin".localized, value: $1.element.vin)))
                                $0.append(.value(.init(title: "comment_reg_number".localized, value: $1.element.gosNumber)))
//                                $0.append(.value(.init(title: "wanted_ovd".localized, value: $1.)))
                                $0.append(.value(.init(title: "comment_title".localized, value: $1.element.title)))
                                $0.append(.value(.init(title: "comment_description".localized, value: $1.element.text)))
                                if $1.offset < model.comments.count - 1 {
                                    $0.append(.separator)
                                }
                            }
                        
                        let additional: [ReportTableItem] = [
                            .description("user_comments_desc".localized),
                            .commentAction
                        ]
                        
                        return items + additional
                    }
                    .startWith([.header(.init(title: headerTitle, state: .empty)), .loader])
            }
            .startWith([.header(.init(title: headerTitle, state: .empty)), .loader])
    }
    
    func makeLockedSection(baseData: Observable<BaseData>, isActiveSubscription: Observable<Bool>) -> Observable<Elements> {
        let riaSection = makeRIASection(baseData: baseData)
        
        return isActiveSubscription
            .distinctUntilChanged()
            .flatMapLatest { isActiveSubscription -> Observable<Elements> in
                guard isActiveSubscription else {
                    let items: [ReportTableItem] = [
                        .locked("ria_title".localized),
                        .locked("recall_title".localized),
                        .locked("dsbt_title".localized),
                        .locked("decoder_title".localized),
                        .locked("complectation_title".localized)
                    ]
                    return .just(items)
                }
                
                return riaSection
            }
            .startWith([])
    }
    
    func makeRIASection(baseData: Observable<BaseData>) -> Observable<Elements> {
        let headerTitle = "ria_title".localized
        
        return baseData
            .distinctUntilChanged { $0.vin == $1.vin && $0.regNumber == $1.regNumber }
            .withUnretained(self)
            .flatMapLatest { base, data -> Observable<Elements> in
                
                guard data.isValidNumber || data.isValidVin else {
                    let type = data.isValidNumber ? "vin_code_type".localized : "gos_number_type".localized
                    let text = String(format: "required_empty_data_warning".localized, type)
                    let items: [ReportTableItem] = [.header(.init(title: headerTitle, state: .error)), .text(text)]
                    let additional = base.additionalActionItems(baseData: data, for: .regNumber, .vin, .technicalPassport)
                    
                    return .just(items + additional)
                }
                
                let regNumber = data.isValidNumber ? data.regNumber : ""
                let vin = data.isValidVin ? data.vin : ""
                
                return base.reportService
                    .getRIA(regNumber: regNumber, vin: vin)
                    .asObservable()
                    .withUnretained(self)
                    .map { base, model -> Elements in
                        guard let model = model, model.result else {
                            return base.errorSection(headerText: headerTitle, message: model?.errorMessage)
                        }
                        
                        guard !model.data.isEmpty else {
                            let text = "no_ria_information_found".localized
                            let items: [ReportTableItem] = [
                                .header(.init(title: headerTitle, state: .error)),
                                .iconWithText(.init(text: text, iconType : .error))
                            ]
                            
                            return items
                        }
                        
                        let initialItems: [ReportTableItem] = [
                            .header(.init(title: headerTitle, state: .success)),
                            .iconWithText(.init(text: String(format: "records".localized, model.data.count), iconType: .error))
                        ]
                        
                        let items: [ReportTableItem] = model.data
                            .enumerated()
                            .reduce(into: initialItems) {
                                if let url = $1.element.photoURL {
                                    $0.append(.photo(url))
                                }
                                $0.append(.value(.init(title: "ria_title_name".localized, value: $1.element.title)))
                                $0.append(.value(.init(title: "ria_vin".localized, value: $1.element.vin)))
                                $0.append(.value(.init(title: "ria_regnumber".localized, value: $1.element.gosNumber)))
                                $0.append(.value(.init(title: "ria_make".localized, value: $1.element.make)))
                                $0.append(.value(.init(title: "ria_model".localized, value: $1.element.model)))
                                $0.append(.value(.init(title: "ria_location".localized, value: $1.element.location)))
                                $0.append(.value(.init(title: "ria_city".localized, value: $1.element.city)))
                                $0.append(.value(.init(title: "ria_date_add".localized, value: $1.element.dateAdd)))
                                $0.append(.value(.init(title: "ria_user_phone".localized, value: $1.element.userPhone)))
                                $0.append(.value(.init(title: "ria_description".localized, value: $1.element.description)))
                                $0.append(.value(.init(title: "ria_year".localized, value: "\($1.element.year)")))
                                $0.append(.value(.init(title: "ria_mileage".localized, value: $1.element.mileage)))
                                $0.append(.value(.init(title: "ria_fuel".localized, value: $1.element.fuel)))
                                $0.append(.value(.init(title: "ria_transmission".localized, value: $1.element.transmission)))
                                $0.append(.value(.init(title: "ria_price_usd".localized, value: "\($1.element.priceUSD)")))
                                $0.append(.value(.init(title: "ria_url".localized, value: $1.element.url)))
                                $0.append(.value(.init(title: "ria_is_leasing".localized, value: ($1.element.isLeasing ? "ria_is_leasing_yes" : "ria_is_leasing_no").localized)))
                                if $1.offset < model.data.count - 1 {
                                    $0.append(.separator)
                                } else {
                                    $0.append(.description("subs_descr_ria".localized))
                                }
                            }
                        
                        return items
                    }
            }
            .startWith([.header(.init(title: headerTitle, state: .empty)), .loader])
    }
}

private extension ReportScreenViewModel {
    
    func errorSection(headerText: String, message: String?) -> Elements {
        return [
            .header(.init(title: headerText, state: .error)),
            .error(message: message ?? "")
        ]
    }
    
    func additionalActionItems(baseData: BaseData, for fieldTypes: ReportValueWithActionModel.FieldType...) -> [ReportTableItem] {
        return fieldTypes
            .compactMap { fieldType -> ReportTableItem? in
                switch fieldType {
                case .vin:
                    if baseData.vin.isEmpty {
                        return .valueWithAction(.init(value: "", action: .add, fieldType: fieldType))
                    }
                    
                    if baseData.vin.contains("_") {
                        return .valueWithAction(.init(value: baseData.vin, action: .change, fieldType: fieldType))
                    }
                    return nil
                case .regNumber:
                    if baseData.regNumber.isEmpty {
                        return .valueWithAction(.init(value: "", action: .add, fieldType: fieldType))
                    }
                    
                    if baseData.regNumber.contains("_") {
                        return .valueWithAction(.init(value: baseData.regNumber, action: .change, fieldType: fieldType))
                    }
                    return nil
                case .technicalPassport:
                    if baseData.technicalPassport.isEmpty {
                        return .valueWithAction(.init(value: "", action: .add, fieldType: fieldType))
                    }
                    return nil
                }
            }
    }
}

private extension ReportScreenViewModel {
    struct BaseData: Equatable {
        var vin: String
        var regNumber: String
        var technicalPassport: String
        
        let isEditableVin: Bool
        let isEditableNumber: Bool
        
        init(vin: String? = nil, regNumber: String? = nil, technicalPassport: String? = nil, isEditableVin: Bool, isEditableNumber: Bool) {
            self.vin = vin ?? ""
            self.regNumber = regNumber ?? ""
            self.technicalPassport = technicalPassport ?? ""
            self.isEditableVin = isEditableVin
            self.isEditableNumber = isEditableNumber
        }
        
        mutating func change(vin: String) {
            self.vin = vin
        }
        
        mutating func change(regNumber: String) {
            self.regNumber = regNumber
        }
        
        mutating func change(passport: String) {
            technicalPassport = passport
        }
        
        var isValidVin: Bool {
            !(vin.isEmpty || vin.contains("_"))
        }
        
        var isValidNumber: Bool {
            !(regNumber.isEmpty || regNumber.contains("_"))
        }
    }
    
    enum Action {
        case baseData(BaseData)
        case input(ReportSearchValue)
    }

}
