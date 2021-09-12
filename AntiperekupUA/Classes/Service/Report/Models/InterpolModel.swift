//
//  InterpolModel.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 12.08.2021.
//

import Foundation

struct InterpolModel {
    let result: Bool
    let errorMessage: String
    let interpol: [Record]
    
    struct Record {
        let recordId: Int
        let addedDate: String
        let theftDate: String
        let engine: String
        let makeModel: String
        let number: String
        let type: String
        let vin: String
    }
}

extension InterpolModel {
    static func map(from response: Any) -> InterpolModel? {
        guard
            let json = response as? [String: Any],
            let data = json["data"] as? [String: Any],
            let result = data["result"] as? Bool,
            let errorMessage = data["error_message"] as? String
        else {
            return nil
        }
        
        let interpol = data["interpol"] as? [[String: Any]] ?? []
        
        return InterpolModel(
            result: result,
            errorMessage: errorMessage,
            interpol: interpol.map { .init(from: $0) })
    }
}

private extension InterpolModel.Record {
    init(from response: [String: Any]) {
        recordId = response["record_id"] as? Int ?? 0
        addedDate = response["date_added"] as? String ?? ""
        theftDate = response["date_theft"] as? String ?? ""
        engine = response["engine"] as? String ?? ""
        makeModel = response["make_model"] as? String ?? ""
        number = response["number"] as? String ?? ""
        type = response["type"] as? String ?? ""
        vin = response["vin"] as? String ?? ""
    }
}
