//
//  GetPhotoRequest.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 14.08.2021.
//

import Alamofire

struct GetPhotoRequest: APIRequestBody {
    private let regNumber: String
    
    init(regNumber: String) {
        self.regNumber = regNumber
    }
    
    var url: String {
        GlobalDefinitions.domainUrl + "/api/ua/get_photos"
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
