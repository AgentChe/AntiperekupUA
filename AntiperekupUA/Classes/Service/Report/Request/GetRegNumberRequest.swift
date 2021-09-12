//
//  GetRegNumberRequest.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 05.08.2021.
//

import Alamofire

struct GetRegNumberRequest: APIRequestBody {
    private let vin: String
    
    init(vin: String) {
        self.vin = vin
    }
    
    var url: String {
        GlobalDefinitions.domainUrl + "/api/ua/get_regnumber_by_vin"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        ["vin": vin]
    }
    
    var headers: HTTPHeaders? {
        HTTPHeaders(defaultHeaders)
    }
    
    var encoding: ParameterEncoding {
        URLEncoding.default
    }
}
