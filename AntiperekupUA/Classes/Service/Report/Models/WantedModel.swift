//
//  WantedModel.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 12.08.2021.
//

import Foundation

struct WantedModel {
    let result: Bool
    let errorMessage: String
    let wanted: [Record]
    
    struct Record {
        let recordId: Int
        let id: String
        let ovd: String
        let brand: String
        let color: String
        let vehicleNumber: String
        let bodyNumber: String
        let chassisNumber: String
        let engineNumber: String
        let theftDate: String
        let insertDate: String
    }
}

extension WantedModel {
    static func map(from response: Any) -> WantedModel? {
        guard
            let json = response as? [String: Any],
            let data = json["data"] as? [String: Any],
            let result = data["result"] as? Bool,
            let errorMessage = data["error_message"] as? String
        else {
            return nil
        }
        
        let wanted = data["wanted"] as? [[String: Any]] ?? []
        
        return WantedModel(
            result: result,
            errorMessage: errorMessage,
            wanted: wanted.map { .init(from: $0) }
        )
    }
}

private extension WantedModel.Record {
    init(from response: [String: Any]) {
        recordId = response["record_id"] as? Int ?? 0
        id = response["id"] as? String ?? ""
        ovd = response["ovd"] as? String ?? ""
        brand = response["brand"] as? String ?? ""
        color = response["color"] as? String ?? ""
        vehicleNumber = response["vehicle_number"] as? String ?? ""
        bodyNumber = response["body_number"] as? String ?? ""
        chassisNumber = response["chassis_number"] as? String ?? ""
        engineNumber = response["engine_number"] as? String ?? ""
        theftDate = response["theft_date"] as? String ?? ""
        insertDate = response["insert_date"] as? String ?? ""
    }
}
