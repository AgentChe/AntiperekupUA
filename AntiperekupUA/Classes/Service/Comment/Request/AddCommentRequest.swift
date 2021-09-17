//
//  AddCommentRequest.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 16.09.2021.
//

import Alamofire

struct AddCommentRequest: APIRequestBody {
    private let regNumber: String
    private let vin: String
    private let title: String
    private let comment: String
    
    init(regNumber: String, vin: String, title: String, comment: String) {
        self.regNumber = regNumber
        self.vin = vin
        self.title = title
        self.comment = comment
    }
    
    var url: String {
        GlobalDefinitions.domainUrl + "/api/ua/add_comment"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "regnumber": regNumber,
            "vin": vin,
            "title": title,
            "description": comment
        ]
    }
    
    var headers: HTTPHeaders? {
        HTTPHeaders(defaultHeaders)
    }
    
    var encoding: ParameterEncoding {
        URLEncoding.default
    }
}
