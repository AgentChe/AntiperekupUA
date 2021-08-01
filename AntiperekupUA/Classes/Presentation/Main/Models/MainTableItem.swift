//
//  MainTableItem.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 27.07.2021.
//

import Foundation
import RxDataSources

enum MainTableItem {
    case action(MainTableAction)
    case error(String)
}

extension MainTableItem: Equatable, Hashable {
}

enum MainTableHeader: String {
    case error
    case action
    case history
}

extension MainTableHeader: IdentifiableType {
    var identity: String {
        return self.rawValue
    }
}

extension MainTableItem: IdentifiableType {
    var identity: Int {
        switch self {
        case let .action(action):
            return action.hashValue
        case let .error(error):
            return error.hashValue
        }
    }
}
