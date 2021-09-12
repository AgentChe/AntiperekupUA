//
//  GetRIARequest.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 15.08.2021.
//

import Alamofire

struct GetRIARequest: APIRequestBody {
    private let regNumber: String
    private let vin: String
    
    init(regNumber: String, vin: String) {
        self.regNumber = regNumber
        self.vin = vin
    }
    
    var url: String {
        GlobalDefinitions.domainUrl + "/api/ua/get_ria"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "regnumber": regNumber,
            "vin": vin
        ]
    }
    
    var headers: HTTPHeaders? {
        HTTPHeaders(defaultHeaders)
    }
    
    var encoding: ParameterEncoding {
        URLEncoding.default
    }
}
