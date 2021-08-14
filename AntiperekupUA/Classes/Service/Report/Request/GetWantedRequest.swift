//
//  GetWantedRequest.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 12.08.2021.
//

import Alamofire

struct GetWantedRequest: APIRequestBody {
    private let regNumber: String
    private let vin: String
    
    init(regNumber: String, vin: String) {
        self.regNumber = regNumber
        self.vin = vin
    }
    
    var url: String {
        GlobalDefinitions.domainUrl + "/api/ua/get_wanted_by_vin_regnumber"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "reg_number": regNumber,
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
