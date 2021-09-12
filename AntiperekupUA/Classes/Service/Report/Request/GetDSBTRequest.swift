//
//  GetDSBTRequest.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 31.08.2021.
//

import Alamofire

struct GetDSBTRequest: APIRequestBody {
    private let regNumber: String
    
    init(regNumber: String) {
        self.regNumber = regNumber
    }
    
    var url: String {
        GlobalDefinitions.domainUrl + "/api/ua/get_dsbt_by_regnumber_subs"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        ["reg_number": regNumber]
    }
    
    var headers: HTTPHeaders? {
        HTTPHeaders(defaultHeaders)
    }
    
    var encoding: ParameterEncoding {
        URLEncoding.default
    }
}
