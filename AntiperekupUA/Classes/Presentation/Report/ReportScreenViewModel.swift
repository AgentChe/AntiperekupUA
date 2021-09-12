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
                    .catchAndReturn(false)
            }
            .share(replay: 1)
        
        let retryTrigger = input.selectedElement
            .asObservable()
            .compactMap { element -> Void? in
                guard case .retry = element else { return nil }
                return ()
            }
        
        let baseDataRequestResult = makeInitialBaseData(retryTrigger: retryTrigger)
            .share(replay: 1)
        
        let baseDataResult = makeBaseData(
            baseData: baseDataRequestResult.compactMap { $0.element },
            inputValue: input.inputValue
        )
        
        let baseDataEvent = Observable.merge(baseDataRequestResult.filter { $0.error != nil }, baseDataResult)
            .share(replay: 1)
        
        let baseData = baseDataEvent
            .compactMap { $0.element }
            .share(replay: 1)
        
        let mainAndHistory = makeMainAndHistorySection(baseData: baseData, retryTrigger: retryTrigger)
            .share(replay: 1)
        
        let lockedSections = makeLockedSection(
            baseData: baseData,
            isActiveSubscription: isActiveSubscription,
            retryTrigger: retryTrigger
        )
        .map { elements -> [DataSource] in
            return elements.map { ("", $0) }
        }
        
        let freeSections = Observable
            .combineLatest([
                makeBaseSection(baseData: baseDataEvent).debug(),
                mainAndHistory.map { $0.main }.debug(),
                mainAndHistory.map { $0.history }.debug(),
                makeWantedSection(baseData: baseData, retryTrigger: retryTrigger).debug(),
                makeInterpolSection(baseData: baseData, retryTrigger: retryTrigger).debug(),
                makePhotosSection(baseData: baseData, retryTrigger: retryTrigger).debug(),
                makeMTSBUSection().debug(),
                makeCommentsSection(baseData: baseData, retryTrigger: retryTrigger).debug(),
                makeAuctionSection(baseData: baseData, isActiveSubscription: isActiveSubscription, retryTrigger: retryTrigger).debug()
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
        baseData: Observable<BaseData>,
        inputValue: Signal<ReportSearchValue>
    ) -> Observable<Event<BaseData>> {
        return Observable<Action>
            .merge(
                baseData.map { .baseData($0) }.debug(),
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
    }
    
    func makeInitialBaseData(retryTrigger: Observable<Void>) -> Observable<Event<BaseData>> {
        let result: Observable<BaseData>
        let startData: BaseData
        
        switch searchValue {
        case let .vin(value):
            startData = BaseData(vin: value, regNumber: nil, technicalPassport: nil, isEditableVin: false, isEditableNumber: true)
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
        case let .regNumber(value):
            // TODO: После реализации WebView поправить конфигурацию данных
            startData = BaseData(regNumber: value, isEditableVin: true, isEditableNumber: false)
            result = .empty()
        case let .technicalPassport(series, number):
            startData = BaseData(vin: nil, regNumber: nil, technicalPassport: "\(series)\(number)", isEditableVin: true, isEditableNumber: true)
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
        }
        
        return result.debug()
            .materialize(with: retryTrigger).debug()
            .startWith(.next(startData))
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
    
    func makeMainAndHistorySection(baseData: Observable<BaseData>, retryTrigger: Observable<Void>) -> Observable<(main: Elements, history: Elements)> {
        let mainTitle = "main_information".localized
        let historyTitle = "registration_history".localized
        
        let loadingSections = (
            main: [ReportTableItem.header(title: mainTitle, state: .empty), .loader],
            history: [ReportTableItem.header(title: historyTitle, state: .empty), .loader]
        )
        
        return baseData
            .distinctUntilChanged { $0.regNumber == $1.regNumber }
            .withUnretained(self).debug()
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
                    .materialize(with: retryTrigger)
                    .compactMap { ReportDataSourceConfigureHelper.mainAndHistory(mainTitle: mainTitle, historyTitle: historyTitle, event: $0) }
                    .startWith(loadingSections)
            }
            .startWith(loadingSections)
    }
    
    func makeWantedSection(baseData: Observable<BaseData>, retryTrigger: Observable<Void>) -> Observable<Elements> {
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
                    .materialize(with: retryTrigger)
                    .compactMap { ReportDataSourceConfigureHelper.wantedSection(headerTitle: headerTitle, event: $0, additional: additional) }
                    .startWith([.header(title: headerTitle, state: .empty), .loader])
            }
            .startWith([.header(title: headerTitle, state: .empty), .loader])
    }
    
    func makeInterpolSection(baseData: Observable<BaseData>, retryTrigger: Observable<Void>) -> Observable<Elements> {
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
                    .materialize(with: retryTrigger)
                    .compactMap { ReportDataSourceConfigureHelper.interpolSection(headerTitle: headerTitle, event: $0)}
                    .startWith([.header(title: headerTitle, state: .empty), .loader])
            }
            .startWith([.header(title: headerTitle, state: .empty), .loader])
    }
    
    func makePhotosSection(baseData: Observable<BaseData>, retryTrigger: Observable<Void>) -> Observable<Elements> {
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
                    .materialize(with: retryTrigger)
                    .compactMap { ReportDataSourceConfigureHelper.photoSection(headerTitle: headerTitle, event: $0) }
                    .startWith([.header(title: headerTitle, state: .empty), .loader])
            }
            .startWith([.header(title: headerTitle, state: .empty), .loader])
    }
    
    func makeMTSBUSection() -> Observable<Elements> {
        // TODO: Реализовать после реализации WebView
        let headerTitle = "mtsbu_title".localized
        
        return .just([.header(title: headerTitle, state: .empty), .text("TODO: Реализовать после реализации WebView")])
    }
    
    func makeCommentsSection(baseData: Observable<BaseData>, retryTrigger: Observable<Void>) -> Observable<Elements> {
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
                    .materialize(with: retryTrigger)
                    .compactMap { ReportDataSourceConfigureHelper.commentsSection(headerTitle: headerTitle, event: $0) }
                    .startWith([.header(title: headerTitle, state: .empty), .loader])
            }
            .startWith([.header(title: headerTitle, state: .empty), .loader])
    }
    
    func makeAuctionSection(
        baseData: Observable<BaseData>,
        isActiveSubscription: Observable<Bool>,
        retryTrigger: Observable<Void>
    ) -> Observable<Elements> {
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
                    .materialize(with: retryTrigger)
                    .compactMap { ReportDataSourceConfigureHelper.auctionSection(headerTitle: headerTitle, event: $0) }
                    .startWith([.header(title: headerTitle, state: .empty), .loader])
            }
            .startWith([.header(title: headerTitle, state: .empty), .loader])
    }
    
    func makeLockedSection(
        baseData: Observable<BaseData>,
        isActiveSubscription: Observable<Bool>,
        retryTrigger: Observable<Void>
    ) -> Observable<[Elements]> {
        let riaSection = makeRIASection(baseData: baseData, retryTrigger: retryTrigger)
        let recallSection = makeRecallSection(baseData: baseData, retryTrigger: retryTrigger)
        let dsbtSection = makeDSBTSection(baseData: baseData, retryTrigger: retryTrigger)
        let decodeVinSection = makeDecodeVinSection(baseData: baseData, retryTrigger: retryTrigger)
        let decodeComplectationSection = makeComplectationSection(baseData: baseData, retryTrigger: retryTrigger)
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
    
    func makeRIASection(baseData: Observable<BaseData>, retryTrigger: Observable<Void>) -> Observable<Elements> {
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
                    .materialize(with: retryTrigger)
                    .compactMap { ReportDataSourceConfigureHelper.riaSection(headerTitle: headerTitle, event: $0) }
                    .startWith([.header(title: headerTitle, state: .empty), .loader])
            }
            .startWith([.header(title: headerTitle, state: .empty), .loader])
    }
    
    func makeRecallSection(baseData: Observable<BaseData>, retryTrigger: Observable<Void>) -> Observable<Elements> {
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
                    .materialize(with: retryTrigger)
                    .compactMap { ReportDataSourceConfigureHelper.recallSection(headerTitle: headerTitle, event: $0) }
                    .startWith([.header(title: headerTitle, state: .empty), .loader])
            }
            .startWith([.header(title: headerTitle, state: .empty), .loader])
    }
    
    func makeDSBTSection(baseData: Observable<BaseData>, retryTrigger: Observable<Void>) -> Observable<Elements> {
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
                    .materialize(with: retryTrigger)
                    .compactMap { ReportDataSourceConfigureHelper.dsbtSection(headerTitle: headerTitle, event: $0) }
                    .startWith([.header(title: headerTitle, state: .empty), .loader])
            }
            .startWith([.header(title: headerTitle, state: .empty), .loader])
    }
    
    func makeDecodeVinSection(baseData: Observable<BaseData>, retryTrigger: Observable<Void>) -> Observable<Elements> {
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
                    .materialize(with: retryTrigger)
                    .compactMap { ReportDataSourceConfigureHelper.decodeVinSection(headerTitle: headerTitle, event: $0) }
                    .startWith([.header(title: headerTitle, state: .empty), .loader])
                
            }
            .startWith([.header(title: headerTitle, state: .empty), .loader])
    }
    
    func makeComplectationSection(baseData: Observable<BaseData>, retryTrigger: Observable<Void>) -> Observable<Elements> {
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
                    .materialize(with: retryTrigger)
                    .compactMap { ReportDataSourceConfigureHelper.complectationSection(headerTitle: headerTitle, event: $0) }
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

extension ReportScreenViewModel {
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

private extension ObservableType {
    func materialize(with retryTrigger: Observable<Void>) -> Observable<Event<Element>> {
        materialize()
            .flatMap { event -> Observable<Event<Element>> in
                guard let error = event.error else {
                    return .just(event)
                }
                
                let second: Observable<Event<Element>> = .error(error)
                return .just(event).concat(second)
            }
            .retry { $0.debug().flatMap { _ in retryTrigger }}
            .debug()
    }
}
