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
