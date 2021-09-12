//
//  DSBTModel.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 31.08.2021.
//

import Foundation

struct DSBTModel {
    let result: Bool
    let errorMessage: String
    let records: [Record]
    
    struct Record {
        let id: Int
        let regNumber: String
        let managmentType: String
        let name: String
        let phone: String
        let shortName: String
        let licenseNum: String
        let startDate: String
        let endDate: String
        let activity: String
        let vehicleStatus: String
        let status: String
        let timestamp: Int
    }
}

extension DSBTModel {
    static func map(from response: Any) -> DSBTModel? {
        guard
            let json = response as? [String: Any],
            let data = json["data"] as? [String: Any],
            let result = data["result"] as? Bool,
            let errorMessage = data["error_message"] as? String
        else {
            return nil
        }
        
        let records = data["data"] as? [[String: Any]] ?? []
        
        return DSBTModel(
            result: result,
            errorMessage: errorMessage,
            records: records.map { .init(from: $0)}
        )
    }
}

extension DSBTModel.Record {
    init(from response: [String: Any]) {
        id = response["record_id"] as? Int ?? 0
        regNumber = response["reg_number"] as? String ?? ""
        managmentType = response["managment_type"] as? String ?? ""
        name = response["name"] as? String ?? ""
        phone = response["phone"] as? String ?? ""
        shortName = response["short_name"] as? String ?? ""
        licenseNum = response["license_num"] as? String ?? ""
        startDate = response["start_date"] as? String ?? ""
        endDate = response["end_date"] as? String ?? ""
        activity = response["activity"] as? String ?? ""
        vehicleStatus = response["vehicle_status"] as? String ?? ""
        status = response["status"] as? String ?? ""
        timestamp = response["timestamp"] as? Int ?? 0
    }
}
