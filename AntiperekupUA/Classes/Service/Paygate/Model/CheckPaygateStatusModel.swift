//
//  CheckPaygateStatusModel.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 29.08.2021.
//

import Foundation

struct CheckPaygateStatusModel {
    let status: Bool
    let errorMessage: String
}

extension CheckPaygateStatusModel {
    init?(from response: Any) {
        guard
            let json = response as? [String: Any],
            let data = json["data"] as? [String: Any],
            let status = data["purchase_status"] as? Bool,
            let errorMessage = data["purchase_message"] as? String
        else {
            return nil
        }
        self.status = status
        self.errorMessage = errorMessage
    }
}
