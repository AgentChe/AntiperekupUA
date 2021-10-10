//
//  DebetsCheckTableData.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 26.09.2021.
//

import Foundation
import RxDataSources

enum DebtsCheckTableItem {
    case error(String)
    case text(String)
    case result(String, Bool)
    case record(DebtsCheckModel.Record)
}

extension DebtsCheckTableItem: Equatable, Hashable { }

enum DebtsCheckHeader: String {
    case error
    case action
}

extension DebtsCheckHeader: IdentifiableType {
    var identity: String {
        return self.rawValue
    }
}

extension DebtsCheckTableItem: IdentifiableType {
    var identity: Int {
        switch self {
        case let .error(error):
            return error.hashValue
        case let .text(text):
            return text.hashValue
        case let .record(record):
            return record.hashValue
        case let .result(text, _):
            return text.hashValue
        }
    }
}
