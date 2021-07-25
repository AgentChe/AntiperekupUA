//
//  LanguageManager.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 24.07.2021.
//

import Foundation

protocol LanguageManager: AnyObject {
    func set(language: LanguageModel)
    func getLanguage() -> LanguageModel
}
