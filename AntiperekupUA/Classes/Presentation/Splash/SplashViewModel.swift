//
//  SplashViewModel.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 24.07.2021.
//

import RxSwift
import RxCocoa

final class SplashViewModel {
    private lazy var sessionManager = SessionManagerCore()
    private lazy var onboardingManager = OnboardingManagerCore()
}

extension SplashViewModel {
    struct Output {
        let showErrorAlert: Signal<(String, String)>
        let showWarningAlert: Signal<(String, String)>
        let start: Signal<Void>
        let nextFlow: Driver<Flow>
    }
    
    enum Flow {
        case main, onboarding
    }
    
    func configure() -> Output {
        let updateTokenResult = sessionManager
            .updateToken()
            .asObservable()
            .materialize()
            .share(replay: 1)
        
        let showErrorAlert = updateTokenResult
            .compactMap { event -> (String, String)? in
                switch event {
                case let .error(error):
                    return ("TITLE", error.localizedDescription)
                case let .next(model):
                    guard let model = model, !model.result else {
                        return nil
                    }
                    let message = model.errorMessage.isEmpty
                        ? "error_message".localized
                        : model.errorMessage
                    
                    return ("TITLE", message)
                case .completed:
                    return nil
                }
            }
            .asSignal(onErrorSignalWith: .empty())
        
        let showWarningAlert = updateTokenResult
            .compactMap { event -> (String, String)? in
                guard case let .next(model) = event, let model = model, !model.messages.isEmpty else { return nil }
                
                let message = model.messages.joined(separator: "\n")
                return ("TITLE", message)
            }
            .asSignal(onErrorSignalWith: .empty())
        
        let startFlow = updateTokenResult
            .compactMap { $0.element }
            .compactMap { element -> Void? in
                guard let model = element else { return nil }
                
                return model.result && model.messages.isEmpty ? () : nil
            }
            .asSignal(onErrorSignalWith: .empty())
        
        let nextFlow = onboardingManager
            .onboardingIsCompleted()
            .map { $0 ? Flow.main : .onboarding }
            .asDriver(onErrorJustReturn: .onboarding)
        
        return Output(
            showErrorAlert: showErrorAlert,
            showWarningAlert: showWarningAlert,
            start: startFlow,
            nextFlow: nextFlow
        )
    }
}
