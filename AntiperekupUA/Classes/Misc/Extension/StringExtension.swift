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
    
    var md5: String {
        let data = Data(self.utf8)
        let hash = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> [UInt8] in
            var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(bytes.baseAddress, CC_LONG(data.count), &hash)
            return hash
        }
        return hash.map { String(format: "%02x", $0) }.joined()
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
}


