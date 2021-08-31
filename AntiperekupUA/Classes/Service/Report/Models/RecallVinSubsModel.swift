//
//  RecallVinSubsModel.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 30.08.2021.
//

import Foundation

struct RecallVinSubsModel {
    let result: Bool
    let errorMessage: String
    let records: [Record]
    
    struct Record {
        let vin: String
        let make: String
        let model: String
        let reason: String
    }
}

extension RecallVinSubsModel {
    static func map(from response: Any) -> RecallVinSubsModel? {
        guard
            let json = response as? [String: Any],
            let data = json["data"] as? [String: Any],
            let result = data["result"] as? Bool,
            let errorMessage = data["error_message"] as? String
        else {
            return nil
        }
        
        let records = data["recall"] as? [[String: Any]] ?? []
        
        return RecallVinSubsModel(
            result: result,
            errorMessage: errorMessage,
            records: records.map { .init(from: $0)}
        )
    }
}

extension RecallVinSubsModel.Record {
    init(from response: [String: Any]) {
        vin = response["vin"] as? String ?? ""
        make = response["make"] as? String ?? ""
        model = response["model"] as? String ?? ""
        reason = response["reason"] as? String ?? ""
    }
}
