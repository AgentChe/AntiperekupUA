//
//  NewCommentCellType.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 12.09.2021.
//

import Foundation

enum NewCommentCellType {
    case selector(current: NewCommentTheme)
    case title
    case comment
    case header(String)
}
