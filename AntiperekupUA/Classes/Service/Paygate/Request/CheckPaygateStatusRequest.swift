//
//  CheckPaygateStatusRequest.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 26.08.2021.
//

import Alamofire

struct CheckPaygateStatusRequest: APIRequestBody {
    private let token: String
    private let productId: String
    
    init(token: String, productId: String) {
        self.token = token
        self.productId = productId
    }
    
    var url: String {
        GlobalDefinitions.domainUrl + "/api/ua/check_subs_token"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "token": token,
            "product_id": productId
        ]
    }
    
    var headers: HTTPHeaders? {
        HTTPHeaders(defaultHeaders)
    }
    
    var encoding: ParameterEncoding {
        URLEncoding.default
    }
}
