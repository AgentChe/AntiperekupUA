//
//  MTSBUScreenViewModel.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 12.10.2021.
//

import RxSwift
import RxCocoa

final class MTSBUScreenViewModel {
    private let regNumber: String
    
    init(regNumber: String) {
        self.regNumber = regNumber
    }
}

extension MTSBUScreenViewModel {
    struct Input {
        let cookies: Signal<[HTTPCookie]>
        let captcha: Signal<MTSBUCaptcha>
        let captchaIsLoaded: Driver<Bool>
        let didTapSkip: Signal<Void>
        let loadError: Signal<Error>
    }
    
    struct Output {
        let cookies: Signal<[HTTPCookie]>
        let searchValue: Signal<ReportSearchValue>
        let errorAlert: Signal<String>
        let retryLoad: Signal<Void>
    }
    
    func configure(input: Input) -> Output {
        
        let captchaSignal = input.captcha
            .asObservable()
            .map { [regNumber] captcha -> Void in
                MTSBUService.shared.set(captcha: captcha, for: regNumber)
                return ()
            }
        
        let searchValue = Observable
            .merge(
                captchaSignal,
                input.didTapSkip.asObservable(),
                input.loadError.asObservable().skip(3).take(1).map { _ in () }
            )
            .map { [regNumber] _ in
                ReportSearchValue.regNumber(regNumber)
            }
            .asSignal(onErrorSignalWith: .empty())
        
        let cookiesResult = input.cookies
            .asObservable()
            .flatMap { cookies -> Observable<Event<MTSBUCookiesModel?>> in
                guard cookies.isEmpty else { return .empty() }
                return MTSBUService.shared.getCookies()
                    .asObservable()
                    .materialize()
            }
            .share(replay: 1)
        
        let errorAlert = cookiesResult
            .compactMap { event -> String? in
                switch event {
                case let .next(element):
                    return element?.result == true
                    ? nil
                    : element?.errorMessage
                case .error:
                    return "request_error".localized
                case .completed:
                    return nil
                }
            }
            .asSignal(onErrorSignalWith: .empty())
        
        let cookies = cookiesResult
            .compactMap { event -> [HTTPCookie]? in
                guard let element = event.element, element?.result == true else {
                    return nil
                }
                
                return element?.cookies
            }
            .asSignal(onErrorSignalWith: .empty())
        
        let retryLoad = input.loadError
            .asObservable()
            .take(3)
            .map { _ in () }
            .asSignal(onErrorSignalWith: .empty())
        
        return Output(
            cookies: cookies,
            searchValue: searchValue,
            errorAlert: errorAlert,
            retryLoad: retryLoad
        )
    }
}

// MARK: Private
private extension MTSBUScreenViewModel {
}
