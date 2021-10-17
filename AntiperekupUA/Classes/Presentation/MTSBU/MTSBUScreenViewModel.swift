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
    private let mtsbuService = MTSBUService()
    
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
    }
    
    struct Output {
        let cookies: Signal<[HTTPCookie]>
        let searchValue: Signal<ReportSearchValue>
        let errorAlert: Signal<String>
    }
    
    func configure(input: Input) -> Output {
        
        let captchaSignal = input.captcha
            .asObservable()
            .do { [mtsbuService] in
                mtsbuService.set(captcha: $0)
            }
            .map { _ in () }
        
        let searchValue = Observable
            .merge(captchaSignal, input.didTapSkip.asObservable())
            .map { [regNumber] _ in
                ReportSearchValue.regNumber(regNumber)
            }
            .asSignal(onErrorSignalWith: .empty())
        
        let cookiesResult = input.cookies
            .asObservable()
            .flatMap { [mtsbuService] cookies -> Observable<Event<MTSBUCookiesModel?>> in
                guard cookies.isEmpty else { return .empty() }
                return mtsbuService.getCookies()
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
        
        return Output(
            cookies: cookies,
            searchValue: searchValue,
            errorAlert: errorAlert
        )
    }
}

// MARK: Private
private extension MTSBUScreenViewModel {
}
