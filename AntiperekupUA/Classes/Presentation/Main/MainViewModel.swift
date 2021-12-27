//
//  MainViewModel.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 25.07.2021.
//

import RxSwift
import RxCocoa

final class MainViewModel {
    typealias TableDataSource = (MainTableHeader, [MainTableItem])
    typealias SearchModel = SearchView.FieldType
    private lazy var auditHistoryService = AuditHistoryManagerCore()
    private lazy var disposeBag = DisposeBag()
    private let isScrollEnabled = BehaviorRelay<Bool>(value: true)
}


extension MainViewModel {
    struct Input {
        let searchValue: Observable<String?>
        let didTapSearch: Signal<Void>
        let tabIndex: Signal<Int>
        let didTapClear: Signal<Void>
        let itemSelected: Signal<MainTableItem>
        let deleteHistoryItem: Signal<MainHistoryItem>
    }
    
    struct Output {
        let tableData: Driver<[TableDataSource]>
        let searchModel: Driver<SearchModel>
        let isError: Driver<Bool>
        let route: Signal<MainRoute>
        let isScrollEnabled: Driver<Bool>
        let savedSearchValue: Driver<String>
    }
    
    func configure(input: Input) -> Output {
        
        let currentTab = input.tabIndex
            .asObservable()
            .compactMap { MainTabType(rawValue: $0) }
            .share(replay: 1)
        
        let inputTextValidation = input.searchValue
            .compactMap { $0 }
            .withLatestFrom(currentTab) { ($0, $1) }
            .map(textValidation)
            .share(replay: 1)

        let textWithTab = currentTab
            .distinctUntilChanged()
            .scan(nil) { old, new -> (current: MainTabType, new: MainTabType)? in
                return (current: old?.new ?? new, new: new)
            }
            .compactMap { $0 }
            .withLatestFrom(input.searchValue.compactMap { $0 }) { ($0.current, $1) }
            .scan([MainTabType: String]()) { old, new in
                var result = old
                result[new.0] = new.1
                return result
            }
        
        let currentText = currentTab
            .withLatestFrom(textWithTab) { tab, elements in
                return elements[tab] ?? ""
            }
            .asDriver(onErrorJustReturn: "")
        
        let searchResult = input.didTapSearch
            .asObservable()
            .withLatestFrom(input.searchValue)
            .withLatestFrom(currentTab) { ($0, $1) }
            .compactMap { [weak self] text, tab -> SearchResult? in
                guard let text = text else { return nil }
                let validCount: Int
                
                let errorMessage: String
                let clearedString = text.filter { !$0.isWhitespace }
                switch tab {
                case .regNumber:
                    validCount = 6
                    errorMessage = Constants.regError
                case .vinNumber:
                    validCount = 10
                    errorMessage =  Constants.vinError + String(format: Constants.example, Constants.vinExample)
                case .technicalPassport:
                    validCount = 9
                    errorMessage = Constants.passportError + String(format: Constants.example, Constants.passportExample)
                }
                
                guard clearedString.count >= validCount else { return .error(errorMessage) }
                return self?.textValidation(text, tab)
            }
            .share(replay: 1)
        
        let searchModel = currentTab
            .map { tab -> SearchModel in
                switch tab {
                case .regNumber:
                    return .regNumber
                case .vinNumber:
                    return .vin
                case .technicalPassport:
                    return .tecnicalPassport
                }
            }
            .asDriver(onErrorDriveWith: .empty())
        
        let isError = Observable
            .merge(
                searchResult.map { $0.isError },
                inputTextValidation.map { $0.isError },
                currentTab.map { _ in false }
            )
            .startWith(false)
            .asDriver(onErrorDriveWith: .empty())
        
        let tableData = buildTableData(
            searchResult: Observable.merge(searchResult, inputTextValidation),
            currentTab: currentTab
        )
        .asDriver(onErrorJustReturn: [])
        
        let itemRoute = input.itemSelected
            .asObservable()
            .compactMap(itemRoute)
        
        let searchRoute = searchResult
            .compactMap(searchResultRoute)
        
        let route = Observable
            .merge(itemRoute, searchRoute)
            .asSignal(onErrorSignalWith: .empty())
        
        input.deleteHistoryItem.asObservable()
            .subscribe(onNext: { [weak self] item in
                self?.auditHistoryService.delete(by: item.id)
            })
            .disposed(by: disposeBag)
        
        input.didTapClear
            .asObservable()
            .subscribe { [auditHistoryService] _ in
                auditHistoryService.deleteAll()
            }
            .disposed(by: disposeBag)
        
        return Output(
            tableData: tableData,
            searchModel: searchModel,
            isError: isError,
            route: route,
            isScrollEnabled: isScrollEnabled.asDriver(),
            savedSearchValue: currentText
        )
    }
}

private extension MainViewModel {
    func buildTableData(searchResult: Observable<SearchResult>, currentTab: Observable<MainTabType>) -> Observable<[TableDataSource]> {
        let mainDataTableData = AuditHistoryMediator.shared.rxItemsChange
            .asObservable()
            .startWith(())
            .map { [auditHistoryService, isScrollEnabled] _ -> [TableDataSource] in
                let elements = auditHistoryService.getHistory()
                    .map { element -> MainTableItem in
                        let historyItem: MainHistoryItem
                        switch element {
                        case let .report(model):
                            let carInfo: String?
                            if !model.brand.isEmpty && !model.model.isEmpty {
                                carInfo = "\(model.brand), \(model.model)"
                            } else {
                                carInfo = nil
                            }
                            
                            let item = MainHistoryItem(
                                id: model.id,
                                date: model.date.relativeDate,
                                mainValue: model.searchValue,
                                additional: carInfo
                            )
                            
                            historyItem = item
                            
                        case let .passport(model):
                            historyItem = MainHistoryItem(
                                id: model.id,
                                date: model.date.relativeDate,
                                mainValue: model.series + model.number,
                                additional: nil
                            )
                            
                        case let .debts(model):
                            let data = model.data
                            let mainValue = "\(data.lastName) \(data.firstName) \(data.patronymic) - \(data.birthday)"
                            historyItem = MainHistoryItem(
                                id: model.id,
                                date: model.date.relativeDate,
                                mainValue: mainValue,
                                additional: nil
                            )
                        }
                        return .history(historyItem)
                    }
                let historyElements = elements.isEmpty ? [.empty] : elements
                isScrollEnabled.accept(!elements.isEmpty)
                return [(.action, [.action(.debets), .action(.passport)]), (.history, historyElements)]
            }
        
        let searchResultDataSource = searchResult
            .map { result -> [TableDataSource] in
                switch result {
                case let .error(error):
                    return [(.error, [.error(error)])]
                default:
                    return []
                }
            }
        
        let searchSource = Observable
            .merge(searchResultDataSource, currentTab.map { _ in [] })
            .startWith([])
        
        return Observable
            .combineLatest(searchSource, mainDataTableData) { $0 + $1 }
    }
    
    var textValidation: (String, MainTabType) -> SearchResult {
        return { text, type -> SearchResult in
            
            let regex = "^[a-zA-Z0-9]*$"
            let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
            
            let clearString = text.filter { !$0.isWhitespace }
            switch type {
            case .regNumber:
                let numberRegex = "^[\\w 0-9]*$"
                let numberPredicate = NSPredicate(format: "SELF MATCHES %@", numberRegex)
                return !numberPredicate.evaluate(with: clearString)
                    ? .error(Constants.regError)
                : .regNumber(clearString.cyrillicToLatinRegNumber)
            case .vinNumber:
                let error = Constants.vinError + String(format: Constants.example, Constants.vinExample)
                return !predicate.evaluate(with: clearString)
                    ? .error(error)
                    : .vinNumber(clearString)
            case .technicalPassport:
                let error = Constants.passportError + String(format: Constants.example, Constants.passportExample)
                let series = String(clearString.prefix(3))
                let number = String(clearString.suffix(clearString.count - series.count))
                
                return !predicate.evaluate(with: clearString)
                ? .error(error)
                : .technicalPassport(series: series, number: number)
            }
        }
    }
    
    var itemRoute: (MainTableItem) -> MainRoute? {
        return { [weak self] item in
            switch item {
            case let .action(action):
                switch action {
                case .debets:
                    return .checkDebets()
                case .passport:
                    return .checkPassport()
                }
            case .error:
                return nil
            case let .history(element):
                guard let item = self?.auditHistoryService.getItem(by: element.id) else {
                    return nil
                }
                
                
                let result: MainRoute
                
                switch item {
                case .report(let model):
                    switch model.searchType {
                    case .regNumber:
                        let cachedModel = MTSBUService.shared.getCache(for: model.searchValue)
                        result = cachedModel == nil
                        ? .regValidation(model.searchValue)
                        : .report(.regNumber(model.searchValue))
                    case .vin:
                        result = .report(.vin(model.searchValue))
                    case .technicalPassport:
                        let series = String(model.searchValue.prefix(3))
                        let number = String(model.searchValue.suffix(model.searchValue.count - series.count))
                        result = .report(.technicalPassport(series: series, number: number))
                    }
                case .passport(let model):
                    result = .checkPassport(series: model.series, number: model.number)
                case .debts(let model):
                    result = .checkDebets(model.data)
                }
                
                
                return result
            case .empty:
                return nil
            }
        }
    }
    
    var searchResultRoute: (SearchResult) -> MainRoute? {
        return { result -> MainRoute? in
            switch result {
            case let .regNumber(value):
                let cache = MTSBUService.shared.getCache(for: value)
                return cache == nil
                ? .regValidation(value)
                : .report(.regNumber(value))
            case let .vinNumber(value):
                return .report(.vin(value))
            case let .technicalPassport(series, number):
                return .report(.technicalPassport(series: series, number: number))
            case .error:
                return nil
            }
        }
    }
}

private extension MainViewModel {
    enum Constants {
        static let regExample = "АА1234ТС"
        static let vinExample = "XTA210990W2395414"
        static let passportExample = "CXI 399999"
        
        static let regError = "reg_number_validation_error".localized
        static let vinError = "vin_validation_error".localized
        static let passportError = "technical_passport_validation_error".localized
        static let example = "example".localized
    }
}

private extension MainViewModel {
    enum SearchResult {
        case regNumber(String)
        case vinNumber(String)
        case technicalPassport(series: String, number: String)
        case error(String)
        
        var isError: Bool {
            switch self {
            case .error:
                return true
            default:
                return false
            }
        }
    }
}
