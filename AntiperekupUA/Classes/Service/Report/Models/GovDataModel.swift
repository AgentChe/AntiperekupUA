//
//  GovDataModel.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 08.08.2021.
//

import Foundation

struct GovDataModel {
    let result: Bool
    let errorMessage: String
    let vehicle: Record?
    let records: [Record]
    
    struct Record {
        let recordId: Int
        let regNumber: String
        let person: String
        let regAddrKoatuu: String
        let operationCode: String
        let operationName: String
        let date: String
        let departamentCode: String
        let departament: String
        let brand: String
        let model: String
        let year: String
        let color: String
        let kind: String
        let body: String
        let purpose: String
        let fuel: String
        let capacity: String
        let ownWeight: String
        let totalWeight: String
        let logo: URL?
        let vin: String
    }
}

extension GovDataModel {
    init?(from response: Any) {
        guard
            let json = response as? [String: Any],
            let data = json["data"] as? [String: Any],
            let result = data["result"] as? Bool,
            let govData = data["gov_data"] as? [String: Any],
            let errorMessage = data["error_message"] as? String
        else {
            return nil
        }
        
        let records = govData["records"] as? [[String: Any]] ?? []
        
        self.result = result
        self.errorMessage = errorMessage
        self.vehicle = (govData["vehicle"] as? [String: Any]).flatMap { .init(from: $0)}
        self.records = records.compactMap { Record(from: $0) }
        
    }
}

private extension GovDataModel.Record{
    init?(from response: [String: Any]) {
        recordId = response["record_id"] as? Int ?? 0
        regNumber = response["reg_number"] as? String ?? ""
        person = response["person"] as? String ?? ""
        regAddrKoatuu = response["reg_addr_koatuu"] as? String ?? ""
        operationCode = response["operation_code"] as? String ?? ""
        operationName = response["operation_name"] as? String ?? ""
        date = response["date"] as? String ?? ""
        departamentCode = response["department_code"] as? String ?? ""
        departament = response["department"] as? String ?? ""
        brand = response["brand"] as? String ?? ""
        model = response["model"] as? String ?? ""
        year = response["year"] as? String ?? ""
        color = response["color"] as? String ?? ""
        kind = response["kind"] as? String ?? ""
        body = response["body"] as? String ?? ""
        purpose = response["purpose"] as? String ?? ""
        fuel = response["fuel"] as? String ?? ""
        capacity = response["capacity"] as? String ?? ""
        ownWeight = response["own_weight"] as? String ?? ""
        totalWeight = response["total_weight"] as? String ?? ""
        logo = (response["logo"] as? String).flatMap { URL(string: $0) }
        vin = response["vin"] as? String ?? ""
    }
}
