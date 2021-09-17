//
//  AddCommentModel.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 16.09.2021.
//

import Foundation

struct AddCommentModel {
    let result: Bool
    let errorMessage: String
}

extension AddCommentModel {
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
    }
}
