//
//  LanguageMediator.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 24.07.2021.
//

import RxSwift
import RxCocoa

final class LanguageMediator {
    static let shared = LanguageMediator()
    
    private var delegates = [Weak<LanguageMediatorDelegate>]()
    
    private lazy var changeAppLocale = PublishRelay<LanguageModel>()
    
    private init() {}
}

extension LanguageMediator {
    func didSaveLocale(locale: LanguageModel) {
        DispatchQueue.main.async { [weak self] in
            self?.delegates.forEach {
                $0.weak?.didSaveLocale(locale: locale)
            }
            
            self?.changeAppLocale.accept(locale)
        }
    }
}

extension LanguageMediator {
    var rxChangeLocale: Signal<LanguageModel> {
        changeAppLocale.asSignal()
    }
}
