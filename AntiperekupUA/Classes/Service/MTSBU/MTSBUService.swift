//
//  MTSBUService.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 13.10.2021.
//

import Foundation
import RxSwift

final class MTSBUService {
    static let shared = MTSBUService()
    
    func set(captcha: MTSBUCaptcha) {
        guard let encodedData = try? JSONEncoder().encode(captcha) else {
            return
        }
        UserDefaults.standard.set(encodedData, forKey: Constants.captchaKey)
    }
    
    func getCaptcha() -> MTSBUCaptcha? {
        guard
            let decodedData = UserDefaults.standard.value(forKey: Constants.captchaKey) as? Data,
            let captcha = try? JSONDecoder().decode(MTSBUCaptcha.self, from: decodedData)
        else {
            return nil
        }
        
        let current = Calendar.current
        let currentComponents = current.dateComponents([.day, .month, .year], from: Date())
        let captchaComponents = current.dateComponents([.day, .month, .year], from: captcha.date)
        
        guard
            currentComponents.month == captchaComponents.month,
            currentComponents.year == captchaComponents.year,
            let currentDay = currentComponents.day,
            let tokenDay = captchaComponents.day,
            currentDay <= tokenDay + 2
        else {
            resetCaptcha()
            return nil
        }
        
        return captcha
    }
    
    func getCookies() -> Single<MTSBUCookiesModel?> {
        let request = MTSBUCookiesRequest()
        
        return RestAPITransport()
            .callServerApi(requestBody: request)
            .map(MTSBUCookiesModel.init)
    }
    
    private func resetCaptcha() {
        UserDefaults.standard.removeObject(forKey: Constants.captchaKey)
    }
}

private extension MTSBUService {
    enum Constants {
        static let captchaKey = "mtsbu_service_captcha_key"
    }
}
