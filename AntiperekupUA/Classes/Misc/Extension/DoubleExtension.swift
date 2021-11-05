//
//  DoubleExtension.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 25.10.2021.
//

import Foundation

extension Double {
    var price: String {
        guard self > 0 else {
            return ""
        }
        return "\(self) $"
    }
}
