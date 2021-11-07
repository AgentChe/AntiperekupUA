//
//  CollectionExtension.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 06.11.2021.
//

import Foundation

extension Collection {
    subscript (safe index: Index) -> Element? {
        self.indices.contains(index) ? self[index] : nil
    }
}
