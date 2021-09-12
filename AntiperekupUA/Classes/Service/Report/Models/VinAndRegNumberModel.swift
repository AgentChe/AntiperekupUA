//
//  VinAndRegNumberModel.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 05.08.2021.
//

import Foundation

struct VinAndRegNumberModel {
    let result: Bool
    let errorMessage: String
    let vin: String?
    let regNumber: String?
}

extension VinAndRegNumberModel {
    static func map(from response: Any) -> VinAndRegNumberModel? {
        guard
            let json = response as? [String: Any],
            let data = json["data"] as? [String: Any],
            let result = data["result"] as? Bool,
            let errorMessage = data["error_message"] as? String
        else {
            return nil
        }
        
        guard result else {
            return VinAndRegNumberModel(result: result, errorMessage: errorMessage, vin: nil, regNumber: nil)
        }
        
        let resultData = data["data"] as? [String: Any]
        
        return VinAndRegNumberModel(
            result: result,
            errorMessage: errorMessage,
            vin: resultData?["vin"] as? String,
            regNumber: resultData?["reg_number"] as? String
        )
    }
}
