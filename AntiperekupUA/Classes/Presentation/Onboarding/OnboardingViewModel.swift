//
//  OnboardingViewModel.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 20.07.2021.
//

import RxSwift
import RxCocoa

final class OnboardingViewModel {
    private lazy var languageManager = LanguageManagerCore()
    private lazy var onboardingManager = OnboardingManagerCore()
    private let disposeBag = DisposeBag()
}

// MARK: Private
private extension OnboardingViewModel {
    
}

extension OnboardingViewModel {
    struct Input {
        let selectedLanguage: Observable<LanguageModel>
        let didTapStart: Signal<Void>
    }
    
    struct Output {
        let showMain: Signal<Void>
    }
    
    func configure(input: Input) -> Output {
        
        input.selectedLanguage
            .subscribe(onNext: { [weak self] model in
                self?.languageManager.set(language: model)
            })
            .disposed(by: disposeBag)
        
        let showMain = input.didTapStart
            .asObservable()
            .flatMapLatest { [onboardingManager] in
                onboardingManager
                    .completeOnboarding()
                    .compactMap { $0 ? () : nil }
            }
            .asSignal(onErrorSignalWith: .empty())
        
        return Output(
            showMain: showMain
        )
    }
}
