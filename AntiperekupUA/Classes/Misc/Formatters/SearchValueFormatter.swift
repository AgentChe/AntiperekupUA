//
//  SearchValueFormatter.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 23.11.2021.
//

import Foundation
import UIKit

struct SearchValueFormatter {
    enum FieldType {
        case regNumber
        case vin
        case technicalPassport
    }
    static func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String, fieldType: FieldType?) -> Bool {
        guard let selectedRange = textField.selectedTextRange, let text = textField.text, let textRange = Range(range, in: text), let fieldType = fieldType else {
            return true
        }
        
        guard fieldType == .technicalPassport else {
            let newString = text.replacingCharacters(in: textRange, with: string)
            return newString.count <= fieldType.maxLength
        }
        
        // Начальная позиция курсора
        var currentPosition = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)
        // Добавляем новый символ в указанную позицию
        let newText = text.replacingCharacters(in: textRange, with: string)
        // Пересчитываем положение курсора в зависимости от добавленного или удаленного символа
        currentPosition += string.isEmpty ? -1 : string.count
        var valueString = ""
        let originalCursorPosition = currentPosition
        
        newText
            .enumerated()
            .forEach { offset, char in
                if char != " " {
                    valueString.append(char)
                } else if offset + 1 <= originalCursorPosition {
                    currentPosition -= 1
                }
            }
        
        valueString = String(valueString.prefix(fieldType.maxLength))
        
        if currentPosition > fieldType.maxLength {
            currentPosition = fieldType.maxLength
        }
        
        var formattedValue = ""
        let currentCursor = currentPosition
        
        valueString
            .enumerated()
            .forEach { offset, char in
                if offset == 3 {
                    formattedValue.append(" ")
                    if offset + 1 <= currentCursor {
                        currentPosition += 1
                    }
                }
                formattedValue.append(char)
            }
        
        // Генерируем событие изменения текста
        textField.text = nil
        textField.insertText(formattedValue)
        
        if let targetPositon = textField.position(from: textField.beginningOfDocument, offset: currentPosition) {
            DispatchQueue.main.async {
                textField.selectedTextRange = textField.textRange(from: targetPositon, to: targetPositon)
            }
        }
        
        return false
    }
}

private extension SearchValueFormatter.FieldType {
    var maxLength: Int {
        switch self {
        case .regNumber:
            return 9
        case .vin:
            return 17
        case .technicalPassport:
            return 9
        }
    }
}
