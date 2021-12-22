//
//  DebtsCheckScreenViewModel.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 24.09.2021.
//

import RxSwift
import RxCocoa

final class DebtsCheckScreenViewModel {
    typealias TableDataSource = (DebtsCheckHeader, [DebtsCheckTableItem])
    private lazy var debtsManager = DebtsManagerCore()
    private lazy var auditHistoryService = AuditHistoryManagerCore()
}

extension DebtsCheckScreenViewModel {
    struct Input {
        let fieldData: Signal<DebtsCheckFieldData>
        let captcha: Signal<DebtsCheckCaptcha>
    }
    
    struct Output {
        let fieldsState: Driver<DebtsCheckFieldState>
        let dataSource: Driver<[TableDataSource]>
        let showError: Signal<String>
        let loadCaptcha: Signal<Void>
        let isLoading: Driver<Bool>
        let showHint: Driver<Bool>
    }
    
    func configure(input: Input) -> Output {
        
        let fieldsState = input.fieldData
            .asObservable()
            .map { data -> DebtsCheckFieldState in
                DebtsCheckFieldState(
                    firstState: data.firstName.isEmpty ? .error : .initial,
                    lastState: data.lastName.isEmpty ? .error : .initial,
                    patronymicState: data.patronymic.isEmpty ? .error : .initial,
                    birthdayState: data.birthday.isEmpty ? .error : .initial,
                    fieldsData: data
                )
            }
            .share(replay: 1)
        
        let validState = fieldsState
            .filter { $0.isValid }
            .share(replay: 1)
        
        let checkDebtsResult = validState
            .do(onNext: { [weak self] in
                self?.auditHistoryService.save(model: .debts(.init(data: $0.fieldsData)))
            })
            .flatMapLatest { [weak self] data in
                return input.captcha
                    .asObservable()
                    .flatMapFirst { [weak self] captcha -> Observable<Event<DebtsCheckModel?>> in
                        guard let self = self else { return .empty() }
                        return self.checkDebts(model: data.fieldsData, captcha: captcha)
                    }
            }
            .share(replay: 1)
        
        let showError = checkDebtsResult
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
            data: checkDebtsResult.compactMap { $0.element }
        )
        .asDriver(onErrorDriveWith: .empty())
        
        let loadingCaptcha = validState
            .map { _ in () }
            .share(replay: 1)
        
        let isLoading = Observable
            .merge(
                loadingCaptcha.map { _ in true },
                checkDebtsResult.map { _ in false }
            )
            .startWith(false)
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
        
        let showHint = fieldsState
            .map { !$0.isValid }
            .startWith(true)
            .asDriver(onErrorDriveWith: .empty())
        
        return Output(
            fieldsState: fieldsState.asDriver(onErrorDriveWith: .empty()),
            dataSource: dataSource,
            showError: showError,
            loadCaptcha: loadingCaptcha.asSignal(onErrorSignalWith: .empty()),
            isLoading: isLoading,
            showHint: showHint
        )
    }
}

// MARK: Private
private extension DebtsCheckScreenViewModel {
    func makeTableData(state: Observable<DebtsCheckFieldState>, data: Observable<DebtsCheckModel?>) -> Observable<[TableDataSource]> {
        Observable.combineLatest(state, data.startWith(nil))
            .map { state, data -> [TableDataSource] in
                guard state.isValid else {
                    return [
                        (.error, [.error("debts_field_error".localized)]),
                        (.action, [.text("seller_duty_hint".localized)])
                    ]
                }
                
                guard let data = data else {
                    return [(.action, [.text("seller_duty_hint".localized)])]
                }
                
                let result = DebtsCheckTableItem.result(
                    data.records.isEmpty ? "debt_not_found".localized : "debt_found".localized,
                    !data.records.isEmpty
                )
                
                let elements: [DebtsCheckTableItem] = data.records
                    .reduce(into: [result]) { $0.append(.record($1)) }
                
                return [(.action, elements)]
            }
            .startWith([(.action, [.text("seller_duty_hint".localized)])])
    }
    
    func checkDebts(model: DebtsCheckFieldData, captcha: DebtsCheckCaptcha) -> Observable<Event<DebtsCheckModel?>> {
        
        return debtsManager.checkDebts(
            firstName: model.firstName,
            lastName: model.lastName,
            patronymic: model.patronymic,
            dob: model.birthday,
            token: captcha.token,
            cookiesString: captcha.cookies
        )
        .asObservable()
        .materialize()
    }
}
