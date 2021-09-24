//
//  AuditHistoryModel.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 22.09.2021.
//

import Foundation

struct AuditHistoryModel {
    let id: String
    let date: Date
    let searchType: SearchType
    let searchValue: String
    let brand: String
    let model: String
    
    enum SearchType: String, Codable {
        case regNumber
        case vin
        case technicalPassport
    }
}

extension AuditHistoryModel: Codable {
    
}

extension AuditHistoryModel {
    
    init(date: Date, searchValue: ReportSearchValue, brand: String, model: String) {
        switch searchValue {
        
        case let .vin(value):
            self.searchType = .vin
            self.searchValue = value
        case let .regNumber(value):
            self.searchType = .regNumber
            self.searchValue = value
        case let .technicalPassport(series, number):
            self.searchType = .technicalPassport
            self.searchValue = series + number
        }
        
        self.brand = brand
        self.model = model
        self.date = date
        self.id = UUID().uuidString
    }
}
