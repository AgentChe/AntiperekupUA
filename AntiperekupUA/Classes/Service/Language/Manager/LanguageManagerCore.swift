//
//  LanguageManagerCore.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 24.07.2021.
//

import Foundation
import UIKit

final class LanguageManagerCore: LanguageManager {
    static let shared = LanguageManagerCore()
    func set(language: LanguageModel) {
        UserDefaults.standard.set(language.rawValue, forKey: Constants.languageKey)
        LanguageMediator.shared.didSaveLocale(locale: language)
    }
    
    func getLanguage() -> LanguageModel {
        if let rawValue = UserDefaults.standard.string(forKey: Constants.languageKey), let language = LanguageModel(rawValue: rawValue) {
            return language
        } else {
            if let deviceLanguageCode = UIDevice.deviceLanguageCode, let language = LanguageModel(rawValue: deviceLanguageCode) {
                set(language: language)
                return language
            } else {
                set(language: .ukraine)
                return .ukraine
            }
        }
    }
    
    
    
}

private extension LanguageManagerCore {
    enum Constants {
        static let languageKey = "language_manager_core_language_key"
    }
}
