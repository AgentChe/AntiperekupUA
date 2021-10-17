//
//  MTSBUCaptcha.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 16.10.2021.
//

import Foundation

struct MTSBUCaptcha {
    let token: String
    let captchaCode: String
    let cookiesString: String
    let date: Date
}

extension MTSBUCaptcha: Codable {
    
}
