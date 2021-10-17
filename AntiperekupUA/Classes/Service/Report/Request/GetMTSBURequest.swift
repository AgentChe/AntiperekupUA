//
//  GetMTSBURequest.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 15.10.2021.
//

import Alamofire

struct GetMTSBURequest: APIRequestBody {
    private let regNumber: String
    private let captchaCode: String
    private let verificationToken: String
    private let cookiesString: String
    
    init(regNumber: String, captchaCode: String, verificationToken: String, cookiesString: String) {
        self.regNumber = regNumber
        self.captchaCode = captchaCode
        self.verificationToken = verificationToken
        self.cookiesString = cookiesString
    }
    
    var url: String {
        GlobalDefinitions.domainUrl + "/api/ua/get_mtsbu_by_regnumber_v2"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "reg_number": regNumber,
            "captcha_code": captchaCode,
            "verification_token": verificationToken,
            "cookies": cookiesString
        ]
    }
    
    var headers: HTTPHeaders? {
        HTTPHeaders(defaultHeaders)
    }
    
    var encoding: ParameterEncoding {
        URLEncoding.default
    }
}

