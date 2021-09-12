//
//  RegNumberModel.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 05.08.2021.
//

import Foundation

struct RegNumberModel {
    let result: Bool
    let errorMessage: String
    let regNumber: String?
}

extension RegNumberModel {
    init?(from response: Any) {
        guard
            let json = response as? [String: Any],
            let data = json["data"] as? [String: Any],
            let result = data["result"] as? Bool,
            let errorMessage = data["error_message"] as? String
        else {
            return nil
        }
        
        self.result = result
        self.errorMessage = errorMessage
        self.regNumber = data["reg_number"] as? String
    }
}
