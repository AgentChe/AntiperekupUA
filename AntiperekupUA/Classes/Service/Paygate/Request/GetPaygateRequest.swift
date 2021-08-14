//
//  GetPaygateRequest.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 05.08.2021.
//

import Alamofire

struct GetPaygateRequest: APIRequestBody {
    private let ssad: String
    
    init(ssad: String) {
        self.ssad = ssad
    }
    
    var url: String {
        GlobalDefinitions.domainUrl + "/api/ua/get_user_subs"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        ["ssad": ssad]
    }
    
    var headers: HTTPHeaders? {
        HTTPHeaders(defaultHeaders)
    }
    
    var encoding: ParameterEncoding {
        URLEncoding.default
    }
}
