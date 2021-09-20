//
//  PassportCheckRequest.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 18.09.2021.
//

import Alamofire

struct PassportCheckRequest: APIRequestBody {
    private let series: String
    private let number: String
    
    init(series: String, number: String) {
        self.series = series
        self.number = number
    }
    
    var url: String {
        GlobalDefinitions.domainUrl + "/api/ua/get_wanted_passport"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "series": series,
            "number": number
        ]
    }
    
    var headers: HTTPHeaders? {
        HTTPHeaders(defaultHeaders)
    }
    
    var encoding: ParameterEncoding {
        URLEncoding.default
    }
}
