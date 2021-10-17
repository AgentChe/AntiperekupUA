//
//  MTSBUCookiesRequest.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 13.10.2021.
//

import Alamofire

struct MTSBUCookiesRequest: APIRequestBody {
    
    var url: String {
        GlobalDefinitions.domainUrl + "/api/ua/get_mtsbu_cookies"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var headers: HTTPHeaders? {
        HTTPHeaders(defaultHeaders)
    }
    
    var encoding: ParameterEncoding {
        URLEncoding.default
    }
}
