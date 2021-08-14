//
//  GetVinAndRegNumberRequest.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 05.08.2021.
//

import Alamofire

struct GetVinAndRegNumberRequest: APIRequestBody {
    private let series: String
    private let number: String
    
    init(series: String, number: String) {
        self.series = series
        self.number = number
    }
    
    var url: String {
        GlobalDefinitions.domainUrl + "/api/ua/get_vin_regnumber_by_regdoc"
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
