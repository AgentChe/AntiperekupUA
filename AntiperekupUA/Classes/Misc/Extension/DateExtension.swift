//
//  DateExtension.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 23.09.2021.
//

import Foundation

extension Date {
    var relativeDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.doesRelativeDateFormatting = true
        dateFormatter.locale = Locale(identifier: "ru_RU")

        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "HH:mm"
        return "\(dateFormatter.string(from: self)), \(timeFormat.string(from: self))"
    }
}
