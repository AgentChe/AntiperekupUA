//
//  RIAModel.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 15.08.2021.
//

import Foundation

struct RIAModel {
    let result: Bool
    let errorMessage: String
    let data: [Record]
    
    struct Record {
        let id: Int
        let autoId: Int
        let vin: String
        let gosNumber: String
        let make: String
        let model: String
        let location: String
        let dateAdd: String
        let userPhone: String
        let description: String
        let year: Int
        let mileage: String
        let fuel: String
        let transmission: String
        let photoURL: URL?
        let priceUSD: Double
        let title: String
        let url: String
        let city: String
        let isLeasing: Bool
    }
}

extension RIAModel {
    static func map(from response: Any) -> RIAModel? {
        guard
            let json = response as? [String: Any],
            let data = json["data"] as? [String: Any],
            let result = data["result"] as? Bool,
            let errorMessage = data["error_message"] as? String
        else {
            return nil
        }
        
        let records = data["data"] as? [[String: Any]] ?? []
        
        return RIAModel(
            result: result,
            errorMessage: errorMessage,
            data: records.map { .init(from: $0) }
        )
    }
}

private extension RIAModel.Record {
    init(from response: [String: Any]) {
        id = response["id"] as? Int ?? 0
        autoId = response["auto_id"] as? Int ?? 0
        vin = response["vin"] as? String ?? ""
        gosNumber = response["gosnumber"] as? String ?? ""
        make = response["make"] as? String ?? ""
        model = response["model"] as? String ?? ""
        location = response["location"] as? String ?? ""
        dateAdd = response["date_add"] as? String ?? ""
        userPhone = response["user_phone"] as? String ?? ""
        description = response["description"] as? String ?? ""
        year = response["year"] as? Int ?? 0
        mileage = response["mileage"] as? String ?? ""
        fuel = response["fuel"] as? String ?? ""
        transmission = response["transmission"] as? String ?? ""
        photoURL = (response["photo_url"] as? String).flatMap { URL(string: $0) }
        priceUSD = response["price_usd"] as? Double ?? 0
        title = response["title"] as? String ?? ""
        url = response["url"] as? String ?? ""
        city = response["city"] as? String ?? ""
        isLeasing = response["is_leasing"] as? Bool ?? false
    }
}
