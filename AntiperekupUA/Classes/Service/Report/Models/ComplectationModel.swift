//
//  ComplectationModel.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 31.08.2021.
//

import Foundation

struct ComplectationModel {
    let result: Bool
    let errorMessage: String
    let records: [Record]
    
    struct Record {
        let title: String
        let value: String
    }
}

extension ComplectationModel {
    static func map(from response: Any) -> ComplectationModel? {
        guard
            let json = response as? [String: Any],
            let data = json["data"] as? [String: Any],
            let result = data["result"] as? Bool,
            let errorMessage = data["error_message"] as? String
        else {
            return nil
        }
        
        let records = data["complectation"] as? [[String: Any]] ?? []
        
        return ComplectationModel(
            result: result,
            errorMessage: errorMessage,
            records: records.map { .init(from: $0)}
        )
    }
}

extension ComplectationModel.Record {
    init(from response: [String: Any]) {
        title = response["title"] as? String ?? ""
        value = response["data"] as? String ?? ""
    }
}
