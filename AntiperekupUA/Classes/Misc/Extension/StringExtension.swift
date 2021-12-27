//
//  StringExtension.swift
//  BabyJournal
//
//  Created by Andrey Chernyshev on 07.11.2020.
//

import Foundation
import CommonCrypto

extension String {
    static func choosePluralForm(byNumber: Int, one: String, two: String, many: String) -> String {
        var result = many
        let number = byNumber % 100
        
        if (number < 10 || number >= 20) {
            if (number % 10 == 1) {
                result = one
            }
            if (number % 10 > 1 && number % 10 < 5) {
                result = two
            }
        }
        return result
    }
    
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    var MD5: String {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        let messageData = self.data(using:.utf8)!
        var digestData = Data(count: length)

        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                        let messageLength = CC_LONG(messageData.count)
                        CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        return digestData.map { String(format: "%02hhx", $0) }.joined()
    }
    
    var cyrillicToLatinRegNumber: Self {
        let cyrillics: [Character] = ["А", "В", "Е", "К", "М", "Н", "О", "Р", "С", "Т", "У", "Х", "І", "І"]
        let latins: [Character] = ["A", "B", "E", "K", "M", "H", "O", "P", "C", "T", "Y", "X", "I", "I"]
        
        let latinsNumber = self.map { char -> Character in
            guard let index = cyrillics.firstIndex(where: { $0 == char }) else {
                return char
            }
            
            return latins[index]
        }
        
        return String(latinsNumber)
    }
}


