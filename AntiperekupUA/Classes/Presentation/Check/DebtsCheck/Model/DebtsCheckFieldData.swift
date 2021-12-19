//
//  DebtsCheckFieldData.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 24.09.2021.
//

import Foundation

struct DebtsCheckFieldData {
    let firstName: String
    let lastName: String
    let patronymic: String
    let birthday: String
}

extension DebtsCheckFieldData: Codable {
    
}
