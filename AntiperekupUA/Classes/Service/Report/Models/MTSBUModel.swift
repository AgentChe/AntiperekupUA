//
//  MTSBUModel.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 15.10.2021.
//

import Foundation

struct MTSBUModel {
    let result: Bool
    let errorMessage: String
    let records: [Record]
    
    struct Record {
        let insurerName: String
        let insurerStatus: String
        let insurerPhone: String
        let insurerEmail: String
        let insurerAddress: String
        let regNumber: String
        let vin: String
        let type: String
        let makeModel: String
        let policyNumber: String
        let timestamp: Int
    }
}

extension MTSBUModel {
    static func map(from response: Any) -> MTSBUModel? {
        guard
            let json = response as? [String: Any],
            let data = json["data"] as? [String: Any],
            let result = data["result"] as? Bool,
            let errorMessage = data["error_message"] as? String
        else {
            return nil
        }
        
        let records = data["data"] as? [[String: Any]] ?? []
        
        return MTSBUModel(
            result: result,
            errorMessage: errorMessage,
            records: records.map { .init(from: $0) }
        )
    }
}

extension MTSBUModel: Codable {}

extension MTSBUModel.Record: Codable {}

private extension MTSBUModel.Record {
    init(from response: [String: Any]) {
        insurerName = response["insurer_name"] as? String ?? ""
        insurerStatus = response["insurer_status"] as? String ?? ""
        insurerPhone = response["insurer_phone"] as? String ?? ""
        insurerEmail = response["insurer_email"] as? String ?? ""
        insurerAddress = response["insurer_address"] as? String ?? ""
        regNumber = response["reg_number"] as? String ?? ""
        vin = response["vin"] as? String ?? ""
        type = response["type"] as? String ?? ""
        makeModel = response["make_model"] as? String ?? ""
        policyNumber = response["policy_number"] as? String ?? ""
        timestamp = response["timestamp"] as? Int ?? 0
    }
}
