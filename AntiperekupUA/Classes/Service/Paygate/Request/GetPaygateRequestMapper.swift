//
//  GetPaygateRequestMapper.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 05.08.2021.
//

import Foundation

enum GetPaygateRequestMapper {
    static func map(from response: Any) -> Bool {
        guard
            let json = response as? [String: Any],
            let data = json["data"] as? [String: Any],
            let userData = data["user_data"] as? [String: Any],
            let isActive = userData["is_subscr_active"] as? Bool
        else {
            return false
        }
        
        return isActive
    }
}
