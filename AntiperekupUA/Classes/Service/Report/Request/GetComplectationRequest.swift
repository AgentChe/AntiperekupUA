//
//  GetComplectationRequest.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 31.08.2021.
//

import Alamofire

struct GetComplectationRequest: APIRequestBody {
    private let vin: String
    
    init(vin: String) {
        self.vin = vin
    }
    
    var url: String {
        GlobalDefinitions.domainUrl + "/api/ua/complectation_vin_subs"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
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
