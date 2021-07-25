//
//  UpdateTokenResponseMapper.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 24.07.2021.
//

import Foundation

struct UpdateTokenResponseMapper {
    static func map(from response: Any) -> UpdateTokenModel? {
        guard
            let json = response as? [String: Any],
            let data = json["data"] as? [String: Any],
            let result = data["result"] as? Bool,
            let errorMessage = data["error_message"] as? String,
            let messages = data["messages"] as? [String]
        else {
            return nil
        }
        
        return UpdateTokenModel(
            result: result,
            errorMessage: errorMessage,
            messages: messages
        )
    }
}
