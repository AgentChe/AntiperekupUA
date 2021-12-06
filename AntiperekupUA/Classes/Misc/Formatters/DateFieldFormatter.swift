//
//  DateFieldFormatter.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 17.11.2021.
//

import Foundation
import UIKit

final class DateFieldFormatter: NSObject, UITextFieldDelegate {
    
    private let maxLength = 8
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let selectedRange = textField.selectedTextRange, let text = textField.text, let textRange = Range(range, in: text) else {
            return true
        }
        
        // Начальная позиция курсора
        var currentPosition = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)
        // Добавляем новый символ в указанную позицию
        let newText = text.replacingCharacters(in: textRange, with: string)
        // Пересчитываем положение курсора в зависимости от добавленного или удаленного символа
        currentPosition += string.isEmpty ? -1 : string.count
        var digitsString = ""
        let originalCursorPosition = currentPosition
        
        newText
            .enumerated()
            .forEach { offset, char in
                if char >= "0" && char <= "9" {
                    digitsString.append(char)
                } else if offset + 1 <= originalCursorPosition {
                    currentPosition -= 1
                }
            }
        
        digitsString = String(digitsString.prefix(maxLength))
        
        if currentPosition > maxLength {
            currentPosition = maxLength
        }
        
        var formattedDate = ""
        let currentCursor = currentPosition
        
        digitsString.enumerated().forEach { offset, char in
            if offset == 2 || offset == 4 {
                formattedDate.append(".")
                if offset + 1 <= currentCursor {
                    currentPosition += 1
                }
            }
            
            formattedDate.append(char)
        }
        
        // Генерируем событие изменения текста
        textField.text = nil
        textField.insertText(formattedDate)
        
        if let targetPositon = textField.position(from: textField.beginningOfDocument, offset: currentPosition) {
            DispatchQueue.main.async {
                textField.selectedTextRange = textField.textRange(from: targetPositon, to: targetPositon)
            }
        }
        
        return false
    }
}
