//
//  ReportSearchValue.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 06.08.2021.
//

import Foundation

enum ReportSearchValue {
    case vin(String)
    case regNumber(String)
    case technicalPassport(series: String, number: String)
}

extension ReportSearchValue {
    init(history: AuditHistoryModel) {
        switch history.searchType {
        case .regNumber:
            self = .regNumber(history.searchValue)
        case .vin:
            self = .vin(history.searchValue)
        case .technicalPassport:
            let clearString = history.searchValue.trimmingCharacters(in: .whitespacesAndNewlines)
            let series = String(clearString.prefix(3))
            let number = String(clearString.suffix(clearString.count - series.count))
            self = .technicalPassport(series: series, number: number)
        }
    }
}
