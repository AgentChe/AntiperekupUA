//
//  AuctionModel.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 30.08.2021.
//

import Foundation

struct AuctionModel {
    let result: Bool
    let errorMessage: String
    let records: [Record]
    
    struct Record {
        let header: String
        let actualPrice: Double
        let repairCost: Double
        let titleState: String
        let location: String
        let odometer: Int
        let primaryDamage: String
        let secondaryDamage: String
        let color: String
        let engine: String
        let cylinders: Int
        let fuel: String
        let keys: String
        let saleDate: String
        let auction: String
        let highlights: String
        let images: [URL]
    }
}

extension AuctionModel {
    static func map(from response: Any) -> AuctionModel? {
        guard
            let json = response as? [String: Any],
            let data = json["data"] as? [String: Any],
            let result = data["result"] as? Bool,
            let errorMessage = data["error_message"] as? String
        else {
            return nil
        }
        
        let records = data["data"] as? [[String: Any]] ?? []
        
        return AuctionModel(
            result: result,
            errorMessage: errorMessage,
            records: records.map { .init(from: $0)}
        )
    }
}

extension AuctionModel.Record {
    init(from response: [String: Any]) {
        header = response["header"] as? String ?? ""
        actualPrice = response["actual_price"] as? Double ?? 0
        repairCost = response["repair_cost"] as? Double ?? 0
        titleState = response["title_state"] as? String ?? ""
        location = response["location"] as? String ?? ""
        odometer = response["odometer"] as? Int ?? 0
        primaryDamage = response["primary_damage"] as? String ?? ""
        secondaryDamage = response["secondary_damage"] as? String ?? ""
        color = response["color"] as? String ?? ""
        engine = response["engine"] as? String ?? ""
        cylinders = response["cylinders"] as? Int ?? 0
        fuel = response["fuel"] as? String ?? ""
        keys = response["keys"] as? String ?? ""
        saleDate = response["sale_date"] as? String ?? ""
        auction = response["auction"] as? String ?? ""
        highlights = response["highlights"] as? String ?? ""
        images = (response["images"] as? [String])?.compactMap { URL(string: $0) } ?? []
    }
}
