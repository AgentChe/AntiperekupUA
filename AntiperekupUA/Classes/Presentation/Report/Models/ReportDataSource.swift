//
//  ReportDataSource.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 05.08.2021.
//

import UIKit
import RxDataSources

struct ReportHeaderModel {
    let title: String
    let state: State
    
    enum State {
        case success
        case error
        case empty
    }
}

struct ReportValueModel {
    let title: String
    let value: String
}

struct ReportIconWithTextModel {
    let text: String
    let iconType: IconType
    
    enum IconType {
        case success
        case error
    }
}

struct ReportValueWithActionModel {
    let value: String
    let action: Action?
    let fieldType: FieldType
    
    enum Action {
        case add
        case change
    }
    
    enum FieldType {
        case vin
        case regNumber
        case technicalPassport
    }
}

enum ReportTableItem {
    case header(ReportHeaderModel)
    case valueWithAction(ReportValueWithActionModel)
    case value(ReportValueModel)
    case separator
    case text(String)
    case iconWithText(ReportIconWithTextModel)
    case error(message: String)
}
