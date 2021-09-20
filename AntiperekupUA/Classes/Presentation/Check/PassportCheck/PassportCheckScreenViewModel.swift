//
//  PassportCheckScreenViewModel.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 17.09.2021.
//

import RxSwift
import RxCocoa

final class PassportCheckScreenViewModel {
    typealias TableDataSource = (PassportCheckHeader, [PassportCheckTableItem])
    private lazy var passportManager = PassportManagerCore()
    private var activityIndicator = RxActivityIndicator()
}

extension PassportCheckScreenViewModel {
    struct Input {
        let fieldData: Signal<(series: String, number: String)>
    }
    
    struct Output {
        let fieldsState: Driver<PassportCheckFieldState>
        let dataSource: Driver<[TableDataSource]>
        let isLoading: Driver<Bool>
        let showError: Signal<String>
    }
    
    func configure(input: Input) -> Output {
        
        let fieldsState = input.fieldData
            .asObservable()
            .map { data -> PassportCheckFieldState in
                PassportCheckFieldState(
                    seriesState: (1...3).contains(data.series.count) ? .initial : .error,
                    series: data.series,
                    numberState: (1...9).contains(data.number.count) ? .initial : .error,
                    number: data.number
                )
            }.debug()
            .share(replay: 1)
        
        let fieldData = fieldsState
            .filter { [$0.seriesState, $0.numberState].allSatisfy { $0 == .initial } }
            .flatMapLatest { [weak self] data -> Observable<Event<PassportCheckModel?>> in
                guard let self = self else { return .empty() }
                return self.checkPassport(series: data.series, number: data.number)
            }
            .share(replay: 1)
        
        let showError = fieldData
            .compactMap { event -> String? in
                switch event {
                
                case let .next(model):
                    if let model = model {
                        return model.result ? nil : model.errorMessage
                    } else {
                        return nil
                    }
                case .error:
                    return "request_error".localized
                case .completed:
                    return nil
                }
            }
            .asSignal(onErrorSignalWith: .empty())
        
        let dataSource = makeTableData(
            state: fieldsState,
            data: fieldData.compactMap { $0.element }
        )
        .asDriver(onErrorDriveWith: .empty())
        
        return Output(
            fieldsState: fieldsState.asDriver(onErrorDriveWith: .empty()),
            dataSource: dataSource,
            isLoading: activityIndicator.asDriver(),
            showError: showError
        )
    }
}

// MARK: Private
private extension PassportCheckScreenViewModel {
    func checkPassport(series: String, number: String) -> Observable<Event<PassportCheckModel?>> {
        return passportManager.checkPassport(series: series, number: number)
            .asObservable()
            .trackActivity(activityIndicator)
            .materialize()
    }
    
    func makeTableData(state: Observable<PassportCheckFieldState>, data: Observable<PassportCheckModel?>) -> Observable<[TableDataSource]> {
        return Observable.combineLatest(state, data.startWith(nil))
            .map { state, data -> [TableDataSource] in
                if let message = state.errorMessage {
                    return [
                        (.error, [.error(message)]),
                        (.action, [.text("wanted_passport_description".localized)])
                    ]
                } else {
                    guard let data = data else {
                        return [(.action, [.text("wanted_passport_description".localized)])]
                    }
                    
                    let result = PassportCheckTableItem.result(
                        data.record == nil ? "no_wanted_passport_information_found".localized : "wanted_passport_information_found".localized,
                        data.record != nil
                    )
                    
                    let record: PassportCheckTableItem? = data.record.map { .record($0) }
                    let elements = [result, record].compactMap { $0 }
                    
                    return [(.action, elements)]
                }
            }
            .startWith([(.action, [.text("wanted_passport_description".localized)])])
    }
}

private extension PassportCheckFieldState {
    var errorMessage: String? {
        switch (seriesState, numberState) {
        case (.error, .error):
            return "passport_number_and_series_error".localized
        case (.initial, .error):
            return "passport_number_error_numbers".localized
        case (.error, .initial):
            return "passport_series_error_numbers".localized
        default:
            return nil
        }
    }
}
