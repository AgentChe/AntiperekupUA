//
//  PassportCheckTableItem.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 18.09.2021.
//

import Foundation
import RxDataSources

enum PassportCheckTableItem {
    case error(String)
    case text(String)
    case result(String, Bool)
    case record(PassportCheckModel.Record)
}

enum PassportCheckHeader: String {
    case error
    case action
}

extension PassportCheckHeader: IdentifiableType {
    var identity: String {
        return self.rawValue
    }
}

extension PassportCheckTableItem: IdentifiableType {
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

extension PassportCheckTableItem: Equatable, Hashable { }
