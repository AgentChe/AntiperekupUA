//
//  GetAuctionRequest.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 30.08.2021.
//

import Alamofire

struct GetAuctionRequest: APIRequestBody {
    private let vin: String
    private let isFree: Bool
    
    init(vin: String, isFree: Bool) {
        self.vin = vin
        self.isFree = isFree
    }
    
    var url: String {
        isFree
            ? GlobalDefinitions.domainUrl + "/api/ua/auction_report_vin_free"
            : GlobalDefinitions.domainUrl + "/api/ua/auction_report_vin_subs"
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

