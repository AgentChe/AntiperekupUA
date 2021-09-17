//
//  NewCommentTheme.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 13.09.2021.
//

import Foundation

enum NewCommentTheme: CaseIterable {
    case mileage
    case myCar
    case soldReseller
    case ownerCheating
    case roadAccident
    case taxi
    case other
}

extension NewCommentTheme {
    var name: String {
        switch self {
        case .mileage:
            return "new_comment_theme_mileage".localized
        case .myCar:
            return "new_comment_theme_my_car".localized
        case .soldReseller:
            return "new_comment_theme_sold_reseller".localized
        case .ownerCheating:
            return "new_comment_theme_owner_cheating".localized
        case .roadAccident:
            return "new_comment_theme_road_accident".localized
        case .taxi:
            return "new_comment_theme_taxi".localized
        case .other:
            return "new_comment_theme_other".localized
        }
    }
}
