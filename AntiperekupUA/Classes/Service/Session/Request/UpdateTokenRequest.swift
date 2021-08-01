//
//  UpdateTokenRequest.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 24.07.2021.
//

import Alamofire

struct UpdateTokenRequest: APIRequestBody {
    private let token: String
    private let ssad: String
    private let versionCode: String
    
    init(token: String, ssad: String, versionCode: String) {
        self.token = token
        self.ssad = ssad
        self.versionCode = versionCode
    }
    
    var url: String {
        GlobalDefinitions.domainUrl + "/api/ua/update_token"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "token": token,
            "ssad": ssad,
            "version_code": versionCode
        ]
    }
    
    var headers: HTTPHeaders? {
        HTTPHeaders(defaultHeaders)
    }
    
    var encoding: ParameterEncoding {
        URLEncoding.default
    }
}
