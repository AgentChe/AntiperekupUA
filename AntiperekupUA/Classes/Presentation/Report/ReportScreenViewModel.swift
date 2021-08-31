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
    
    private lazy var purchaseService = PurchaseManagerCore()
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
        let activateSubscription: Signal<Void>
    }
    
    struct Output {
        let elements: Driver<[DataSource]>
        let showChangeAlert: Signal<ReportValueWithActionModel>
        let isActiveSubscription: Driver<Bool>
    }
    
    func configure(input: Input) -> Output {
        
        let isActiveSubscription = input.activateSubscription
            .asObservable()
            .startWith(())
            .flatMapLatest { [purchaseService] _ in
                purchaseService.isActiveSubscription()
                    .asObservable()
            }
            .share(replay: 1)
        
        let searchValue = Observable.just(searchValue)
        
        let retryTrigger = input.selectedElement
            .asObservable()
            .compactMap { element -> Void? in
                guard case .retry = element else { return nil }
                return ()
            }
        
        let baseDataResult = makeBaseData(
            searchValue: searchValue,
            inputValue: input.inputValue,
            retryTrigger: retryTrigger
        )
        .share(replay: 1, scope: .forever)
        
        let baseData = baseDataResult
            .compactMap { $0.element }
            .share(replay: 1, scope: .forever)
        
        let mainAndHistory = makeMainAndHistorySection(baseData: baseData)
            .share(replay: 1)
        
        let lockedSections = makeLockedSection(baseData: baseData, isActiveSubscription: isActiveSubscription)
            .map { elements -> [DataSource] in
                return elements.map { ("", $0) }
            }
        
        let freeSections = Observable
            .combineLatest([
                makeBaseSection(baseData: baseDataResult),
                mainAndHistory.map { $0.main },
                mainAndHistory.map { $0.history },
                makeWantedSection(baseData: baseData),
                makeInterpolSection(baseData: baseData),
                makePhotosSection(baseData: baseData),
                makeMTSBUSection(),
                makeCommentsSection(baseData: baseData),
                makeAuctionSection(baseData: baseData, isActiveSubscription: isActiveSubscription)
            ]) { elements -> [DataSource] in
                return elements.map { ("", $0) }
            }
        
        let elements = Observable
            .combineLatest(freeSections, lockedSections) { $0 + $1 }
            .asDriver(onErrorDriveWith: .empty())
        
        let showChangeAlert = input.selectedElement
            .asObservable()
            .compactMap { element -> ReportValueWithActionModel? in
                guard case let .valueWithAction(model) = element, model.action != .none else { return nil }
                
                return model
            }
            .asSignal(onErrorSignalWith: .empty())
        
        return Output(
            elements: elements,
            showChangeAlert: showChangeAlert,
            isActiveSubscription: isActiveSubscription.asDriver(onErrorJustReturn: false)
        )
    }
    
    
}

// MARK: Private
private extension ReportScreenViewModel {
    
    func makeBaseData(
        searchValue: Observable<ReportSearchValue>,
        inputValue: Signal<ReportSearchValue>,
        retryTrigger: Observable<Void>
    ) -> Observable<Event<BaseData>> {
        let baseData = searchValue
            .flatMapLatest { [reportService] value -> Observable<Event<BaseData>> in
                let result: Observable<BaseData>
                
                switch value {
                case let .vin(value):
                    result = reportService
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
                        .startWith(BaseData(vin: value, regNumber: nil, technicalPassport: nil, isEditableVin: false, isEditableNumber: true))
                case let .regNumber(value):
                    // TODO: После реализации WebView поправить конфигурацию данных
                    result = .just(BaseData(regNumber: value, isEditableVin: true, isEditableNumber: false))
                case let .technicalPassport(series, number):
                    result = reportService
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
                        .startWith(BaseData(vin: nil, regNumber: nil, technicalPassport: "\(series)\(number)", isEditableVin: true, isEditableNumber: true))
                }
                
                return result
                    .materialize()
                    .flatMap { event -> Observable<Event<BaseData>> in
                        guard case let .error(error) = event else {
                            return .just(event)
                        }
                        
                        let second: Observable<Event<BaseData>> = .error(error)
                        return .just(event).concat(second)
                    }
                    .retry(when: { $0.flatMap { _ in retryTrigger } })
                    .debug()
            }
            .share(replay: 1)
        
        let successResult = Observable<Action>
            .merge(
                baseData.compactMap { $0.element.map { .baseData($0) } },
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
            .compactMap { $0.map { Event.next($0) } }
        
        return Observable.merge(successResult, baseData.filter { $0.error != nil }).debug()
    }
    
    func makeBaseSection(baseData: Observable<Event<BaseData>>) -> Observable<Elements> {
        let headerTitle = "basic_information".localized
        
        return baseData
            .compactMap { event -> Elements? in
                switch event {
                case let .next(model):
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
                    
                    return [
                        .header(title: headerTitle, state: .empty),
                        .valueWithAction(regNumber),
                        .valueWithAction(vin),
                        .valueWithAction(technicalPassport)
                    ]
                case let .error(error):
                    var errorMessage: String {
                        switch (error as NSError).code {
                        case NSURLErrorNotConnectedToInternet:
                            return "network_error".localized
                        case NSURLErrorTimedOut:
                            return "timeout_error".localized
                        default:
                            return ""
                        }
                    }
                    
                    return [
                        .header(title: headerTitle, state: .error),
                        .error(message: errorMessage),
                        .retry
                    ]
                case .completed:
                    return nil
                }
                
            }
            .startWith([.header(title: headerTitle, state: .empty), .loader])
    }
    
    func makeMainAndHistorySection(baseData: Observable<BaseData>) -> Observable<(main: Elements, history: Elements)> {
        let mainTitle = "main_information".localized
        let historyTitle = "registration_history".localized
        
        let loadingSections = (
            main: [ReportTableItem.header(title: mainTitle, state: .empty), .loader],
            history: [ReportTableItem.header(title: historyTitle, state: .empty), .loader]
        )
        
        return baseData
            .distinctUntilChanged { $0.regNumber == $1.regNumber }
            .withUnretained(self)
            .flatMapLatest { base, data -> Observable<(main: Elements, history: Elements)> in
                
                guard data.isValidNumber else {
                    let text = String(format: "required_empty_data_warning".localized, "gos_number_type".localized)
                    let mainItems: Elements = [
                        .header(title: mainTitle, state: .error),
                        .text(text)
                    ]
                    
                    let historyItems: Elements = [
                        .header(title: historyTitle, state: .error),
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
                        
                        let main: Elements = model.vehicle
                            .map { vehicle in
                                [
                                    .header(title: mainTitle, state: .success),
                                    vehicle.logo.map { .logo($0) },
                                    .value(title: "gov_data_regnumber".localized, value: vehicle.regNumber),
                                    .value(title: "gov_data_vin".localized, value: vehicle.vin),
                                    .value(title: "gov_data_brand".localized, value: vehicle.brand),
                                    .value(title: "gov_data_model".localized, value: vehicle.model),
                                    .value(title: "gov_data_color".localized, value: vehicle.color),
                                    .value(title: "gov_data_body".localized, value: vehicle.body),
                                    .value(title: "gov_data_purpose".localized, value: vehicle.purpose),
                                    .value(title: "gov_data_kind".localized, value: vehicle.kind),
                                    .value(title: "gov_data_capacity".localized, value: vehicle.capacity),
                                    .value(title: "gov_data_year".localized, value: vehicle.year),
                                    .value(title: "gov_data_fuel".localized, value: vehicle.fuel),
                                    .value(title: "gov_data_own_weight".localized, value: vehicle.ownWeight),
                                    .value(title: "gov_data_total_weight".localized, value: vehicle.totalWeight),
                                    .description("subs_descr_gov_data".localized)
                                ].compactMap { $0 }
                            } ?? [
                                .header(title: mainTitle, state: .error),
                                .iconWithText(.init(text: "no_gov_data_information_found".localized, iconType: .error)),
                                .description("subs_descr_gov_data".localized)
                            ]
                        
                        var initialHistory: Elements {
                            let isEmpty = model.records.isEmpty
                            let text = isEmpty ? "no_gov_data_information_found".localized : String(format: "records".localized, model.records.count)
                            
                            let result: ReportTableItem = .iconWithText(.init(text: text, iconType: isEmpty ? .error : .success))
                            let header: ReportTableItem = .header(title: historyTitle, state: isEmpty ? .error : .success)
                            
                            return [header, result]
                        }
                        
                        let history: Elements = model.records
                            .enumerated()
                            .reduce(into: initialHistory) {
                                $0.append(.value(title: "gov_data_date".localized, value: $1.element.date))
                                $0.append(.value(title: "gov_data_person".localized, value: $1.element.person))
                                $0.append(.value(title: "gov_data_regnumber".localized, value: $1.element.regNumber))
                                $0.append(.value(title: "gov_data_vin".localized, value: $1.element.vin))
                                $0.append(.value(title: "gov_data_brand".localized, value: $1.element.brand))
                                $0.append(.value(title: "gov_data_model".localized, value: $1.element.model))
                                $0.append(.value(title: "gov_data_year".localized, value: $1.element.year))
                                $0.append(.value(title: "gov_data_color".localized, value: $1.element.color))
                                $0.append(.value(title: "gov_data_department".localized, value: $1.element.departament))
                                $0.append(.value(title: "gov_data_department_code".localized, value: $1.element.departamentCode))
                                $0.append(.value(title: "gov_data_operation_code".localized, value: $1.element.operationCode))
                                $0.append(.value(title: "gov_data_operation_name".localized, value: $1.element.operationName))
                                $0.append(.value(title: "gov_data_reg_addr_koatuu".localized, value: $1.element.regAddrKoatuu))
                                if $1.offset < model.records.count - 1 {
                                    $0.append(.separator)
                                }
                            } + [.description("subs_descr_gov_data".localized)]
                        
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
                    let items: Elements = [.header(title: headerTitle, state: .error), .text(text)]
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
                                .header(title: headerTitle, state: .success),
                                .iconWithText(.init(text: text, iconType : .success)),
                                .description("subs_descr_wanted".localized)
                            ]
                        }
                        
                        let recordCount = ReportTableItem.iconWithText(.init(text: String(format: "records_wanted".localized, model.wanted.count), iconType: .error))
                        
                        let items: Elements = model.wanted
                            .enumerated()
                            .reduce(into: [.header(title: headerTitle, state: .error), recordCount]) {
                                $0.append(.value(title: "wanted_ovd".localized, value: $1.element.ovd))
                                $0.append(.value(title: "wanted_brand".localized, value: $1.element.brand))
                                $0.append(.value(title: "wanted_color".localized, value: $1.element.color))
                                $0.append(.value(title: "wanted_vehicle_number".localized, value: $1.element.vehicleNumber))
                                $0.append(.value(title: "wanted_body_number".localized, value: $1.element.bodyNumber))
                                $0.append(.value(title: "wanted_chassis_number".localized, value: $1.element.chassisNumber))
                                $0.append(.value(title: "wanted_engine_number".localized, value: $1.element.engineNumber))
                                $0.append(.value(title: "wanted_theft_date".localized, value: $1.element.theftDate))
                                $0.append(.value(title: "wanted_insert_date".localized, value: $1.element.insertDate))
                                if $1.offset < model.wanted.count - 1 {
                                    $0.append(.separator)
                                } else {
                                    $0.append(.description("subs_descr_wanted".localized))
                                }
                            }
                        
                        return items + additional
                    }
                    .startWith([.header(title: headerTitle, state: .empty), .loader])
            }
            .startWith([.header(title: headerTitle, state: .empty), .loader])
    }
    
    func makeInterpolSection(baseData: Observable<BaseData>) -> Observable<Elements> {
        let headerTitle = "interpol_title".localized
        
        return baseData
            .distinctUntilChanged { $0.vin == $1.vin }
            .withUnretained(self)
            .flatMapLatest { base, data -> Observable<Elements> in
                
                guard data.isValidVin else {
                    let text = String(format: "required_empty_data_warning".localized, "vin_code_type".localized)
                    
                    let items: Elements = [
                        .header(title: headerTitle, state: .error),
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
                            let items: Elements = [
                                .header(title: headerTitle, state: .success),
                                .iconWithText(.init(text: "no_interpol_information_found".localized, iconType: .success)),
                                .description("subs_descr_interpol".localized)
                            ]
                            return items
                        }
                        
                        let recordCount = ReportTableItem.iconWithText(.init(text: String(format: "records_wanted".localized, model.interpol.count), iconType: .error))
                        
                        let items: Elements = model.interpol
                            .enumerated()
                            .reduce(into: [.header(title: headerTitle, state: .error), recordCount]) {
                                $0.append(.value(title: "interpol_vin".localized, value: $1.element.vin))
                                $0.append(.value(title: "interpol_number".localized, value: $1.element.number))
                                $0.append(.value(title: "interpol_date_added".localized, value: $1.element.addedDate))
                                $0.append(.value(title: "interpol_date_theft".localized, value: $1.element.theftDate))
                                $0.append(.value(title: "interpol_engine".localized, value: $1.element.engine))
                                $0.append(.value(title: "interpol_type".localized, value: $1.element.type))
                                $0.append(.value(title: "interpol_make_model".localized, value: $1.element.makeModel))
                                if $1.offset < model.interpol.count - 1 {
                                    $0.append(.separator)
                                } else {
                                    $0.append(.description("subs_descr_interpol".localized))
                                }
                            }
                        
                        return items
                    }
                    .startWith([.header(title: headerTitle, state: .empty), .loader])
            }
            .startWith([.header(title: headerTitle, state: .empty), .loader])
    }
    
    func makePhotosSection(baseData: Observable<BaseData>) -> Observable<Elements> {
        let headerTitle = "photos_title".localized
        
        return baseData
            .distinctUntilChanged { $0.regNumber == $1.regNumber }
            .withUnretained(self)
            .flatMapLatest { base, data -> Observable<Elements> in
                
                guard data.isValidNumber else {
                    let text = String(format: "required_empty_data_warning".localized, "gos_number_type".localized)
                    
                    let items: Elements = [
                        .header(title: headerTitle, state: .error),
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
                        
                        var initialItems: Elements {
                            let isEmpty = model.photos.isEmpty
                            let text = isEmpty ? "no_photos_information_found".localized : String(format: "photos".localized, model.photos.count)
                            
                            let result: ReportTableItem = .iconWithText(.init(text: text, iconType: isEmpty ? .error : .success))
                            let header: ReportTableItem = .header(title: headerTitle, state: isEmpty ? .error : .success)
                            
                            return [header, result]
                        }
                        
                        let items: Elements = model.photos
                            .enumerated()
                            .reduce(into: initialItems) {
                                $0.append(.value(title: "photos_make".localized, value: $1.element.make))
                                $0.append(.value(title: "photos_model".localized, value: $1.element.model))
                                $0.append(.value(title: "photos_date".localized, value: $1.element.date))
                                if let url = $1.element.url {
                                    $0.append(.photo(url))
                                }
                                
                                if $1.offset < model.photos.count - 1 {
                                    $0.append(.separator)
                                }
                        } + [.description("subs_descr_photos".localized)]
                        
                        
                        return items
                    }
                    .startWith([.header(title: headerTitle, state: .empty), .loader])
            }
            .startWith([.header(title: headerTitle, state: .empty), .loader])
    }
    
    func makeMTSBUSection() -> Observable<Elements> {
        // TODO: Реализовать после реализации WebView
        let headerTitle = "mtsbu_title".localized
        
        return .just([.header(title: headerTitle, state: .empty), .text("TODO: Реализовать после реализации WebView")])
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
                    let items: Elements = [.header(title: headerTitle, state: .error), .text(text)]
                    
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
                        
                        let additional: Elements = [
                            .description("user_comments_desc".localized),
                            .commentAction
                        ]
                        
                        guard !model.comments.isEmpty else {
                            let text = "user_comments_not_found".localized
                            let items: Elements = [
                                .header(title: headerTitle, state: .error),
                                .iconWithText(.init(text: text, iconType : .error))
                            ]
                            
                            return items + additional
                        }
                        
                        let initialItems: Elements = [
                            .header(title: headerTitle, state: .success),
                            .iconWithText(.init(text: "user_comments_found".localized, iconType: .success))
                        ]
                        
                        let items: Elements = model.comments
                            .enumerated()
                            .reduce(into: initialItems) {
                                $0.append(.complain(id: $1.element.id))
                                $0.append(.value(title: "comment_vin".localized, value: $1.element.vin))
                                $0.append(.value(title: "comment_reg_number".localized, value: $1.element.gosNumber))
//                                $0.append(.value(title: "wanted_ovd".localized, value: $1.))
                                $0.append(.value(title: "comment_title".localized, value: $1.element.title))
                                $0.append(.value(title: "comment_description".localized, value: $1.element.text))
                                if $1.offset < model.comments.count - 1 {
                                    $0.append(.separator)
                                }
                            }
                        
                        return items + additional
                    }
                    .startWith([.header(title: headerTitle, state: .empty), .loader])
            }
            .startWith([.header(title: headerTitle, state: .empty), .loader])
    }
    
    func makeAuctionSection(baseData: Observable<BaseData>, isActiveSubscription: Observable<Bool>) -> Observable<Elements> {
        let headerTitle = "preview_title".localized
        
        return Observable
            .combineLatest(
                baseData.distinctUntilChanged { $0.vin == $1.vin },
                isActiveSubscription.distinctUntilChanged()
            )
            .withUnretained(self)
            .flatMapLatest { base, tuple -> Observable<Elements> in
                let (data, isActiveSubscription) = tuple
                guard data.isValidVin else {
                    let text = String(format: "required_empty_data_warning".localized, "vin_code_type".localized)
                    
                    let items: Elements = [
                        .header(title: headerTitle, state: .error),
                        .text(text)
                    ]
                    
                    let additional = base.additionalActionItems(baseData: data, for: .vin, .technicalPassport)
                    return .just(items + additional)
                }
                
                return base.reportService
                    .getAuction(vin: data.vin, isFree: !isActiveSubscription)
                    .asObservable()
                    .withUnretained(self)
                    .map { base, model -> Elements in
                        guard let model = model, model.result else {
                            return base.errorSection(headerText: headerTitle, message: model?.errorMessage)
                        }
                        
                        guard !model.records.isEmpty else {
                            let items: Elements = [
                                .header(title: headerTitle, state: .success),
                                .iconWithText(.init(text: "no_preview_information_found".localized, iconType: .success)),
                                .description("subs_descr_preview".localized)
                            ]
                            return items
                        }
                        
                        let initialItems: [ReportTableItem] = [
                            .header(title: headerTitle, state: .error),
                            .iconWithText(.init(text: String(format: "records".localized, model.records.count), iconType: .error))
                        ]
                        
                        return model.records
                            .enumerated()
                            .reduce(into: initialItems) {
                                $0.append(.value(title: "auction_header".localized, value: $1.element.header))
                                $0.append(.value(title: "auction_actual_price".localized, value: $1.element.actualPrice.price))
                                $0.append(.value(title: "auction_repair_cost".localized, value: $1.element.repairCost.price))
                                $0.append(.value(title: "auction_title_state".localized, value: $1.element.titleState))
                                $0.append(.value(title: "auction_location".localized, value: $1.element.location))
                                $0.append(.value(title: "auction_odometer".localized, value: "\($1.element.odometer)"))
                                $0.append(.value(title: "auction_primary_damage".localized, value: $1.element.primaryDamage))
                                $0.append(.value(title: "auction_secondary_damage".localized, value: $1.element.secondaryDamage))
                                $0.append(.value(title: "auction_color".localized, value: $1.element.color))
                                $0.append(.value(title: "auction_engine".localized, value: $1.element.engine))
                                $0.append(.value(title: "auction_cylinders".localized, value: "\($1.element.cylinders)"))
                                $0.append(.value(title: "auction_fuel".localized, value: $1.element.fuel))
                                $0.append(.value(title: "auction_keys".localized, value: $1.element.keys))
                                $0.append(.value(title: "auction_highlights".localized, value: $1.element.highlights))
                                if !$1.element.images.isEmpty {
                                    $0.append(.images($1.element.images))
                                }
                                if $1.offset < model.records.count - 1 {
                                    $0.append(.separator)
                                } else {
                                    $0.append(.description("subs_descr_preview".localized))
                                }
                            }
                    }
                    .startWith([.header(title: headerTitle, state: .empty), .loader])
            }
            .startWith([.header(title: headerTitle, state: .empty), .loader])
    }
    
    func makeLockedSection(baseData: Observable<BaseData>, isActiveSubscription: Observable<Bool>) -> Observable<[Elements]> {
        let riaSection = makeRIASection(baseData: baseData)
        let recallSection = makeRecallSection(baseData: baseData)
        let dsbtSection = makeDSBTSection(baseData: baseData)
        let decodeVinSection = makeDecodeVinSection(baseData: baseData)
        let decodeComplectationSection = makeComplectationSection(baseData: baseData)
        let disposalSection = makeDisposalSection()
        
        return isActiveSubscription
            .distinctUntilChanged()
            .flatMapLatest { isActiveSubscription -> Observable<[Elements]> in
                guard isActiveSubscription else {
                    let items: Elements = [
                        .locked("ria_title".localized),
                        .locked("recall_title".localized),
                        .locked("dsbt_title".localized),
                        .locked("decoder_title".localized),
                        .locked("complectation_title".localized)
                    ]
                    return .just([items])
                }
                
                return Observable
                    .combineLatest([
                        riaSection,
                        recallSection,
                        dsbtSection,
                        decodeVinSection,
                        decodeComplectationSection,
                        disposalSection
                    ])
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
                    let items: Elements = [.header(title: headerTitle, state: .error), .text(text)]
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
                            let items: Elements = [
                                .header(title: headerTitle, state: .error),
                                .iconWithText(.init(text: text, iconType : .error)),
                                .description("subs_descr_ria".localized)
                            ]
                            
                            return items
                        }
                        
                        let initialItems: Elements = [
                            .header(title: headerTitle, state: .success),
                            .iconWithText(.init(text: String(format: "records".localized, model.data.count), iconType: .error))
                        ]
                        
                        return model.data
                            .enumerated()
                            .reduce(into: initialItems) {
                                if let url = $1.element.photoURL {
                                    $0.append(.photo(url))
                                }
                                $0.append(.value(title: "ria_title_name".localized, value: $1.element.title))
                                $0.append(.value(title: "ria_vin".localized, value: $1.element.vin))
                                $0.append(.value(title: "ria_regnumber".localized, value: $1.element.gosNumber))
                                $0.append(.value(title: "ria_make".localized, value: $1.element.make))
                                $0.append(.value(title: "ria_model".localized, value: $1.element.model))
                                $0.append(.value(title: "ria_location".localized, value: $1.element.location))
                                $0.append(.value(title: "ria_city".localized, value: $1.element.city))
                                $0.append(.value(title: "ria_date_add".localized, value: $1.element.dateAdd))
                                $0.append(.value(title: "ria_user_phone".localized, value: $1.element.userPhone))
                                $0.append(.value(title: "ria_description".localized, value: $1.element.description))
                                $0.append(.value(title: "ria_year".localized, value: "\($1.element.year)"))
                                $0.append(.value(title: "ria_mileage".localized, value: $1.element.mileage))
                                $0.append(.value(title: "ria_fuel".localized, value: $1.element.fuel))
                                $0.append(.value(title: "ria_transmission".localized, value: $1.element.transmission))
                                $0.append(.value(title: "ria_price_usd".localized, value: "\($1.element.priceUSD)"))
                                $0.append(.value(title: "ria_url".localized, value: $1.element.url))
                                $0.append(.value(title: "ria_is_leasing".localized, value: ($1.element.isLeasing ? "ria_is_leasing_yes" : "ria_is_leasing_no").localized))
                                if $1.offset < model.data.count - 1 {
                                    $0.append(.separator)
                                } else {
                                    $0.append(.description("subs_descr_ria".localized))
                                }
                            }
                    }
            }
            .startWith([.header(title: headerTitle, state: .empty), .loader])
    }
    
    func makeRecallSection(baseData: Observable<BaseData>) -> Observable<Elements> {
        let headerTitle = "recall_title".localized
        
        return baseData
            .distinctUntilChanged { $0.vin == $1.vin }
            .withUnretained(self)
            .flatMapLatest { base, data -> Observable<Elements> in
                guard data.isValidVin else {
                    let text = String(format: "required_empty_data_warning".localized, "vin_code_type".localized)
                    
                    let items: Elements = [
                        .header(title: headerTitle, state: .error),
                        .text(text)
                    ]
                    
                    let additional = base.additionalActionItems(baseData: data, for: .vin, .technicalPassport)
                    return .just(items + additional)
                }
                
                return base.reportService
                    .getRecall(vin: data.vin)
                    .asObservable()
                    .withUnretained(self)
                    .map { base, model -> Elements in
                        guard let model = model, model.result else {
                            return base.errorSection(headerText: headerTitle, message: model?.errorMessage)
                        }
                        
                        guard !model.records.isEmpty else {
                            let items: Elements = [
                                .header(title: headerTitle, state: .success),
                                .iconWithText(.init(text: "no_recall_information_found".localized, iconType: .success)),
                                .description("subs_descr_recall".localized)
                            ]
                            return items
                        }
                        
                        let recordCount = ReportTableItem.iconWithText(.init(text: String(format: "records".localized, model.records.count), iconType: .error))
                        
                        return model.records
                            .enumerated()
                            .reduce(into: [.header(title: headerTitle, state: .error), recordCount]) {
                                $0.append(.value(title: "recall_vin".localized, value: $1.element.vin))
                                $0.append(.value(title: "recall_make".localized, value: $1.element.make))
                                $0.append(.value(title: "recall_model".localized, value: $1.element.model))
                                $0.append(.value(title: "recall_reason".localized, value: $1.element.reason))
                                if $1.offset < model.records.count - 1 {
                                    $0.append(.separator)
                                } else {
                                    $0.append(.description("subs_descr_recall".localized))
                                }
                            }
                    }
                    .startWith([.header(title: headerTitle, state: .empty), .loader])
            }
            .startWith([.header(title: headerTitle, state: .empty), .loader])
    }
    
    func makeDSBTSection(baseData: Observable<BaseData>) -> Observable<Elements> {
        let headerTitle = "dsbt_title".localized
        
        return baseData
            .distinctUntilChanged { $0.regNumber == $1.regNumber }
            .withUnretained(self)
            .flatMapLatest { base, data -> Observable<Elements> in
                
                guard data.isValidNumber else {
                    let text = String(format: "required_empty_data_warning".localized, "gos_number_type".localized)
                    
                    let items: [ReportTableItem] = [
                        .header(title: headerTitle, state: .error),
                        .text(text)
                    ]
                    
                    let additional = base.additionalActionItems(baseData: data, for: .regNumber, .technicalPassport)
                    return .just(items + additional)
                }
                
                return base.reportService
                    .getDSBT(regNumber: data.regNumber)
                    .asObservable()
                    .withUnretained(base)
                    .map { base, model -> Elements in
                        guard let model = model, model.result else {
                            return base.errorSection(headerText: headerTitle, message: model?.errorMessage)
                        }
                        
                        guard !model.records.isEmpty else {
                            let text = "no_dsbt_information_found".localized
                            let items: [ReportTableItem] = [
                                .header(title: headerTitle, state: .success),
                                .iconWithText(.init(text: text, iconType : .error)),
                                .description("subs_descr_dsbt".localized)
                            ]
                            
                            return items
                        }
                        
                        let initialItems: Elements = [
                            .header(title: headerTitle, state: .error),
                            .iconWithText(.init(text: String(format: "records".localized, model.records.count), iconType: .error))
                        ]
                        
                        return model.records
                            .enumerated()
                            .reduce(into: initialItems) {
                                let managmentType = $1.element.managmentType.isEmpty
                                    ? ""
                                    : $1.element.managmentType.uppercased() == "NATURAL"
                                    ? "natural_type".localized
                                    : "legal_type".localized
                                
                                $0.append(.value(title: "dsbt_regnumber".localized, value: $1.element.regNumber))
                                $0.append(.value(title: "dsbt_managment_type".localized, value: managmentType))
                                $0.append(.value(title: "dsbt_name".localized, value: $1.element.name))
                                $0.append(.value(title: "dsbt_short_name".localized, value: $1.element.shortName))
                                $0.append(.value(title: "dsbt_license_num".localized, value: $1.element.licenseNum))
                                $0.append(.value(title: "dsbt_start_date".localized, value: $1.element.startDate))
                                $0.append(.value(title: "dsbt_end_date".localized, value: $1.element.endDate))
                                $0.append(.value(title: "dsbt_activity".localized, value: $1.element.activity))
                                $0.append(.value(title: "dsbt_vehicle_status".localized, value: $1.element.vehicleStatus))
                                $0.append(.value(title: "dsbt_status".localized, value: $1.element.status))
                                if $1.offset < model.records.count - 1 {
                                    $0.append(.separator)
                                } else {
                                    $0.append(.description("subs_descr_dsbt".localized))
                                }
                            }
                    }
                    .startWith([.header(title: headerTitle, state: .empty), .loader])
            }
            .startWith([.header(title: headerTitle, state: .empty), .loader])
    }
    
    func makeDecodeVinSection(baseData: Observable<BaseData>) -> Observable<Elements> {
        let headerTitle = "decoder_title".localized
        
        return baseData
            .distinctUntilChanged { $0.vin == $1.vin }
            .withUnretained(self)
            .flatMapLatest { base, data -> Observable<Elements> in
                guard data.isValidVin else {
                    let text = String(format: "required_empty_data_warning".localized, "vin_code_type".localized)
                    
                    let items: Elements = [
                        .header(title: headerTitle, state: .error),
                        .text(text)
                    ]
                    
                    let additional = base.additionalActionItems(baseData: data, for: .vin, .technicalPassport)
                    return .just(items + additional)
                }
                
                return base.reportService
                    .getDecodeVin(vin: data.vin)
                    .asObservable()
                    .withUnretained(base)
                    .map { base, model -> Elements in
                        guard let model = model, model.result else {
                            return base.errorSection(headerText: headerTitle, message: model?.errorMessage)
                        }
                        
                        guard !model.records.isEmpty else {
                            let items: Elements = [
                                .header(title: headerTitle, state: .success),
                                .iconWithText(.init(text: "no_decoder_information_found".localized, iconType: .error)),
                                .description("subs_descr_decoder".localized)
                            ]
                            return items
                        }
                        
                        let logoItem: ReportTableItem? = model.records
                            .first(where: { $0 .isLogo })
                            .flatMap { $0.logoURL }
                            .map { .logo($0) }
                        
                        let initialItems: Elements = [
                            .header(title: headerTitle, state: .success),
                            .iconWithText(.init(text: "decoder_success".localized, iconType: .success)),
                            logoItem
                        ].compactMap { $0 }
                        
                        return model.records
                            .reduce(into: initialItems) {
                                switch $1 {
                                case let .title(title):
                                    $0.append(.title(title))
                                case let .value(title, value):
                                    $0.append(.value(title: title, value: value))
                                case .logo:
                                    break
                                }
                            } + [.description("subs_descr_decoder".localized)]
                    }
                    .startWith([.header(title: headerTitle, state: .empty), .loader])
                
            }
            .startWith([.header(title: headerTitle, state: .empty), .loader])
    }
    
    func makeComplectationSection(baseData: Observable<BaseData>) -> Observable<Elements> {
        let headerTitle = "complectation_title".localized
        
        return baseData
            .distinctUntilChanged { $0.vin == $1.vin }
            .withUnretained(self)
            .flatMapLatest { base, data -> Observable<Elements> in
                guard data.isValidVin else {
                    let text = String(format: "required_empty_data_warning".localized, "vin_code_type".localized)
                    
                    let items: [ReportTableItem] = [
                        .header(title: headerTitle, state: .error),
                        .text(text)
                    ]
                    
                    let additional = base.additionalActionItems(baseData: data, for: .vin, .technicalPassport)
                    return .just(items + additional)
                }
                
                return base.reportService
                    .getComplectation(vin: data.vin)
                    .asObservable()
                    .withUnretained(base)
                    .map { base, model -> Elements in
                        guard let model = model, model.result else {
                            return base.errorSection(headerText: headerTitle, message: model?.errorMessage)
                        }
                        
                        guard !model.records.isEmpty else {
                            let items: Elements = [
                                .header(title: headerTitle, state: .success),
                                .iconWithText(.init(text: "no_complectation_information_found".localized, iconType: .error)),
                                .description("subs_descr_complectation".localized)
                            ]
                            return items
                        }
                        
                        let initialItems: Elements = [
                            .header(title: headerTitle, state: .success),
                            .iconWithText(.init(text: "decoder_success".localized, iconType: .success)),
                        ]
                        
                        return model.records
                            .reduce(into: initialItems) {
                                $0.append(.value(title: $1.title, value: $1.value))
                            } + [.description("subs_descr_complectation".localized)]
                    }
                    .startWith([.header(title: headerTitle, state: .empty), .loader])
                
            }
            .startWith([.header(title: headerTitle, state: .empty), .loader])
    }
    
    func makeDisposalSection() -> Observable<Elements> {
        let items: Elements = [
            .header(title: "disposal_title".localized, state: .success),
            .iconWithText(.init(text: "no_disposal_information_found".localized, iconType: .success))
        ]
        return .just(items)
    }
}

private extension ReportScreenViewModel {
    
    func errorSection(headerText: String, message: String?) -> Elements {
        return [
            .header(title: headerText, state: .error),
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

private extension Double {
    var price: String {
        guard self > 0 else {
            return ""
        }
        return "\(self) $"
    }
}
