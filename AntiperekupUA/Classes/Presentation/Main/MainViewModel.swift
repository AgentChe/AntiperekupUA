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
    
    private lazy var auditHistoryService = AuditHistoryManagerCore()
    private lazy var disposeBag = DisposeBag()
}


extension MainViewModel {
    struct Input {
        let searchValue: Observable<String>
        let tabIndex: Signal<Int>
        let didTapClear: Signal<Void>
        let itemSelected: Signal<MainTableItem>
        let deleteHistoryItem: Signal<MainHistoryItem>
    }
    
    struct Output {
        let tableData: Driver<[TableDataSource]>
        let searchPlaceholder: Driver<String>
        let isError: Driver<Bool>
        let route: Signal<MainRoute>
    }
    
    func configure(input: Input) -> Output {
        
        let currentTab = input.tabIndex
            .asObservable()
            .compactMap { MainTabType(rawValue: $0) }
            .share(replay: 1)
        
        let searchResult = input.searchValue
            .asObservable()
            .withLatestFrom(currentTab, resultSelector: textValidation)
            .share(replay: 1)
        
        let searchPlaceholder = currentTab
            .map { tab -> String in
                switch tab {
                case .regNumber:
                    return Constants.regExample
                case .vinNumber:
                    return Constants.vinExample
                case .technicalPassport:
                    return Constants.passportExample
                }
            }
            .asDriver(onErrorDriveWith: .empty())
        
        let isError = searchResult
            .map { $0.isError }
            .startWith(false)
            .asDriver(onErrorDriveWith: .empty())
        
        let tableData = buildTableData(searchResult: searchResult)
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
        
        return Output(
            tableData: tableData,
            searchPlaceholder: searchPlaceholder,
            isError: isError,
            route: route
        )
    }
}

private extension MainViewModel {
    func buildTableData(searchResult: Observable<SearchResult>) -> Observable<[TableDataSource]> {
        let mainDataTableData = AuditHistoryMediator.shared.rxItemsChange
            .asObservable()
            .startWith(())
            .map { [auditHistoryService] _ -> [TableDataSource] in
                let historyElements = auditHistoryService.getAuditHistory()
                    .map { model -> MainTableItem in
                        let carInfo: String?
                        if !model.brand.isEmpty && !model.model.isEmpty {
                            carInfo = "\(model.brand), \(model.model)"
                        } else {
                            carInfo = nil
                        }
                        
                        let item = MainHistoryItem(
                            id: model.id,
                            date: model.date.relativeDate,
                            searchValue: model.searchValue,
                            carInfo: carInfo
                        )
                        
                        return .history(item)
                    }
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
            .startWith([])
        
        return Observable
            .combineLatest(searchResultDataSource, mainDataTableData) { $0 + $1 }
    }
    
    var textValidation: (String, MainTabType) -> SearchResult {
        return { text, type -> SearchResult in
            
            let clearString = text.trimmingCharacters(in: .whitespacesAndNewlines)
            switch type {
            case .regNumber:
                return clearString.count >= 6
                    ? .regNumber(clearString)
                    : .error(Constants.regError)
            case .vinNumber:
                let error = Constants.vinError + String(format: Constants.example, Constants.vinExample)
                guard clearString.count >= 10 else { return .error(error) }
                let regex = "^[a-zA-Z0-9]*$"
                let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
                return predicate.evaluate(with: clearString)
                    ? .vinNumber(clearString)
                    : .error(error)
            case .technicalPassport:
                let error = Constants.passportError + String(format: Constants.example, Constants.passportExample)
                guard clearString.count >= 9 else { return .error(error) }
                let series = String(clearString.prefix(3))
                let number = String(clearString.suffix(clearString.count - series.count))
                return .technicalPassport(series: series, number: number)
            }
        }
    }
    
    var itemRoute: (MainTableItem) -> MainRoute? {
        return { [weak self] item in
            switch item {
            case let .action(action):
                switch action {
                case .debets:
                    return .checkDebets
                case .passport:
                    return .checkPassport
                }
            case .error:
                return nil
            case let .history(element):
                guard let item = self?.auditHistoryService.getItem(by: element.id) else {
                    return nil
                }
                let result: MainRoute
                switch item.searchType {
                case .regNumber:
                    let captcha = MTSBUService.shared.getCaptcha()
                    result = captcha == nil
                    ? .regValidation(item.searchValue)
                    : .report(.regNumber(item.searchValue))
                case .vin:
                    result = .report(.vin(item.searchValue))
                case .technicalPassport:
                    let series = String(item.searchValue.prefix(3))
                    let number = String(item.searchValue.suffix(item.searchValue.count - series.count))
                    result = .report(.technicalPassport(series: series, number: number))
                }
                
                return result
            }
        }
    }
    
    var searchResultRoute: (SearchResult) -> MainRoute? {
        return { result -> MainRoute? in
            switch result {
            case let .regNumber(value):
                let captcha = MTSBUService.shared.getCaptcha()
                return captcha == nil
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
        static let regExample = "X77XX77"
        static let vinExample = "XTA210990w2395414"
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
