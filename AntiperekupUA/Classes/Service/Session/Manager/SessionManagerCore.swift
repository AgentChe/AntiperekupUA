//
//  SessionManagerCore.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 24.07.2021.
//

import Foundation
import UIKit
import RxSwift
import Firebase

final class SessionManagerCore: SessionManager {
    static let shared = SessionManagerCore()
    
    var uuid: String {
        get {
            if let uuid = UserDefaults.standard.string(forKey: Constants.uuidKey) {
                return uuid
            } else {
                let uuid = UUID().uuidString
                UserDefaults.standard.set(uuid, forKey: Constants.uuidKey)
                return uuid
            }
        }
    }
    
    var sign: String {
        let key1 = Data(base64Encoded: GlobalDefinitions.key1, options: Data.Base64DecodingOptions(rawValue: 0))
            .flatMap { String(data: $0, encoding: .utf8) } ?? ""
        let key2 = Data(base64Encoded: GlobalDefinitions.key2, options: Data.Base64DecodingOptions(rawValue: 0))
            .flatMap { String(data: $0, encoding: .utf8) } ?? ""
        
        return ((uuid + key1).uppercased().MD5 + key2).uppercased().MD5.uppercased()
    }
    
    func updateToken() -> Single<UpdateTokenModel?> {
        let appVersion = UIDevice.appVersion ?? ""
        let versionCode = appVersion.compactMap { $0 == "." ? nil : $0 }
                        + appVersion.compactMap { $0 == "." ? "0" : nil }
        
        let request = UpdateTokenRequest(
            token: Messaging.messaging().fcmToken ?? "",
            ssad: UIDevice.idfv ?? "",
            versionCode: String(versionCode)
        )
        
        return RestAPITransport()
            .callServerApi(requestBody: request)
            .map(UpdateTokenResponseMapper.map(from:))
    }
}

private extension SessionManagerCore {
    enum Constants {
        static let uuidKey = "session_manager_core_uuid_key"
    }
}
