//
//  MTSBUCookiesModel.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 13.10.2021.
//

import Foundation

struct MTSBUCookiesModel {
    let result: Bool
    let errorMessage: String
    let cookies: [HTTPCookie]
}

extension MTSBUCookiesModel {
    init?(from response: Any) {
        guard
            let json = response as? [String: Any],
            let data = json["data"] as? [String: Any],
            let result = data["result"] as? Bool,
            let errorMessage = data["error_message"] as? String,
            let cookies = data["data"] as? [String: Any]
        else {
            return nil
        }
        
        self.result = result
        self.errorMessage = errorMessage
        self.cookies = cookies.compactMap {
            .init(properties: [
                .name: $0.key,
                .value: $0.value,
                .path: "/",
                .secure: false,
                .domain: ".mtsbu.ua"
            ])
        }
    }
}
