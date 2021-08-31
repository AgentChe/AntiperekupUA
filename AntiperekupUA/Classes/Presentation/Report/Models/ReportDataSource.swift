//
//  ReportDataSource.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 05.08.2021.
//

import UIKit
import RxDataSources

enum ReportHeaderState {
    case success
    case error
    case empty
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
    case header(title: String, state: ReportHeaderState)
    case valueWithAction(ReportValueWithActionModel)
    case value(title: String, value: String)
    case separator
    case text(String)
    case iconWithText(ReportIconWithTextModel)
    case error(message: String)
    case loader
    case logo(URL)
    case photo(URL)
    case commentAction
    case complain(id: Int)
    case locked(String)
    case description(String)
    case images([URL])
    case title(String)
    case retry
}
