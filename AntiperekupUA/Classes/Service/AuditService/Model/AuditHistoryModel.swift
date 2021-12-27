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

extension AuditHistoryModel: Equatable {
    static func == (lhs: AuditHistoryModel, rhs: AuditHistoryModel) -> Bool {
        return lhs.searchType == rhs.searchType && lhs.searchValue == rhs.searchValue
    }
}

extension PassportModel: Equatable {
    static func == (lhs: PassportModel, rhs: PassportModel) -> Bool {
        return lhs.number == rhs.number && lhs.series == rhs.series
    }
}

extension DebtsModel: Equatable {}

enum History {
    case report(AuditHistoryModel)
    case passport(PassportModel)
    case debts(DebtsModel)
}

extension History: Hashable {
    static func == (lhs: History, rhs: History) -> Bool {
        switch (lhs, rhs) {
        case (.report(let first), .report(let second)):
            return first == second
        case (.passport(let first), .passport(let second)):
            return first == second
        case (.debts(let first), .debts(let second)):
            return first.data == second.data
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .report(let auditHistoryModel):
            hasher.combine(auditHistoryModel.searchValue)
        case .passport(let passportModel):
            hasher.combine(passportModel.number)
            hasher.combine(passportModel.series)
        case .debts(let debtsModel):
            hasher.combine(debtsModel.data)
        }
    }
}

extension History: Codable {
    enum CodingKeys: CodingKey {
        case report, passport, debts
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case let .report(model):
            try container.encode(model, forKey: .report)
        case let .passport(model):
            try container.encode(model, forKey: .passport)
        case let .debts(model):
            try container.encode(model, forKey: .debts)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = container.allKeys.first
        
        switch key {
        case .report:
            let model = try container.decode(AuditHistoryModel.self, forKey: .report)
            self = .report(model)
        case .passport:
            let model = try container.decode(PassportModel.self, forKey: .passport)
            self = .passport(model)
        case .debts:
            let model = try container.decode(DebtsModel.self, forKey: .debts)
            self = .debts(model)
        case .none:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unabled to decode enum."
                )
            )
        }
    }
}

struct DebtsModel: Codable {
    let id: String
    let date: Date
    let data: DebtsCheckFieldData
}

extension DebtsModel {
    init(data: DebtsCheckFieldData) {
        id = UUID().uuidString
        date = Date()
        self.data = data
    }
}

struct PassportModel: Codable {
    let id: String
    let date: Date
    let number: String
    let series: String
}

extension PassportModel {
    init(series: String, number: String) {
        id = UUID().uuidString
        date = Date()
        self.series = series
        self.number = number
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
