//
//  PassportCheckModel.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 18.09.2021.
//

import Foundation

struct PassportCheckModel {
    let result: Bool
    let errorMessage: String
    let record: Record?
    
    struct Record {
        let recordId: Int
        let id: String
        let ovd: String
        let series: String
        let number: String
        let type: String
        let status: String
        let theftDate: String
        let insertDate: String
    }
}

extension PassportCheckModel {
    static func map(from response: Any) -> PassportCheckModel? {
        guard
            let json = response as? [String: Any],
            let data = json["data"] as? [String: Any],
            let result = data["result"] as? Bool,
            let errorMessage = data["error_message"] as? String
        else {
            return nil
        }
        
        let record = data["wanted"] as? [String: Any] ?? [:]
        
        return PassportCheckModel(
            result: result,
            errorMessage: errorMessage,
            record: .init(from: record)
        )
    }
}

private extension PassportCheckModel.Record {
    init?(from response: [String: Any]) {
        guard
            let recordId = response["record_id"] as? Int,
            let id = response["id"] as? String,
            let ovd = response["ovd"] as? String,
            let series = response["series"] as? String,
            let number = response["number"] as? String,
            let type = response["type"] as? String,
            let status = response["status"] as? String,
            let theftDate = response["theft_date"] as? String,
            let insertDate = response["insert_date"] as? String
        else {
            return nil
        }
        
        self.recordId = recordId
        self.id = id
        self.ovd = ovd
        self.series = series
        self.number = number
        self.type = type
        self.status = status
        self.theftDate = theftDate
        self.insertDate = insertDate
    }
}

extension PassportCheckModel.Record: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(recordId)
    }
}
