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
    
}


extension MainViewModel {
    struct Input {
        let searchValue: Observable<String>
        let tabIndex: Signal<Int>
        let didTapClear: Signal<Void>
        let itemSelected: Signal<MainTableItem>
    }
    
    struct Output {
        let tableData: Driver<[TableDataSource]>
        let searchPlaceholder: Driver<String>
//        let searchResult: Signal<SearchResult>
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
        
        let mainDataSource: [TableDataSource] = [(.action, [.action(.debets), .action(.passport)]), (.history, [])]
        
        let tableData = searchResult
            .map { result -> [TableDataSource] in
                switch result {
                case let .error(error):
                    return [(.error, [.error(error)])] + mainDataSource
                default:
                    return mainDataSource
                }
            }
            .startWith(mainDataSource)
            .asDriver(onErrorJustReturn: [])
        
        let itemRoute = input.itemSelected
            .asObservable()
            .compactMap(itemRoute)
        
        let searchRoute = searchResult
            .compactMap(searchResultRoute)
        
        let route = Observable
            .merge(itemRoute, searchRoute)
            .asSignal(onErrorSignalWith: .empty())
        
        return Output(
            tableData: tableData,
            searchPlaceholder: searchPlaceholder,
            isError: isError,
            route: route
        )
    }
}

private extension MainViewModel {
    
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
        return { item in
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
            }
        }
    }
    
    var searchResultRoute: (SearchResult) -> MainRoute? {
        return { result -> MainRoute? in
            switch result {
            case let .regNumber(number):
                return .regValidation(number)
            case .vinNumber:
                return .report
            case .technicalPassport:
                return .report
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
        
        static let regError = "Минимальная длина госномера 6 символов."
        static let vinError = "VIN код может содержать только латинские буквы и цифры."
        static let passportError = "Техпаспорт может содержать только латинские буквы и цифры."
        static let example = "\nНапример: %@"
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
