//
//  GetRecallVinSubsRequest.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 30.08.2021.
//

import Alamofire

struct GetRecallVinSubsRequest: APIRequestBody {
    private let vin: String
    
    init(vin: String) {
        self.vin = vin
    }
    
    var url: String {
        GlobalDefinitions.domainUrl + "/api/ua/recall_vin_subs"
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
