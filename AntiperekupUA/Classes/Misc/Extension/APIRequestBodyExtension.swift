//
//  APIRequestBodyExtension.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 24.07.2021.
//

import Foundation
import Alamofire

extension APIRequestBody {
    var defaultHeaders: [HTTPHeader] {
        [
            HTTPHeader(name: "AS-LANG", value: LanguageManagerCore.shared.getLanguage().rawValue),
            HTTPHeader(name: "AS-UUID", value: SessionManagerCore.shared.uuid),
            HTTPHeader(name: "AS-SIGN", value: SessionManagerCore.shared.sign),
            HTTPHeader(name: "AS-CLIENT", value: "ios"),
            HTTPHeader(name: "AS-VERSION", value: GlobalDefinitions.appVersion),
            HTTPHeader(name: "AS_USER_TYPE", value: "free"),
            HTTPHeader(name: "X-REQUEST_ID", value: UUID().uuidString),
            HTTPHeader(name: "AS-APP-NAME", value: "autocheck_ua_ios"),
            HTTPHeader(name: "AS-SSAD", value: GlobalDefinitions.ssad),
        ]
    }
}
