//
//  MainRoute.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 01.08.2021.
//

import Foundation

enum MainRoute {
    case regValidation(String)
    case checkPassport(series: String? = nil, number: String? = nil)
    case checkDebets(DebtsCheckFieldData? = nil)
    case report(ReportSearchValue)
}
