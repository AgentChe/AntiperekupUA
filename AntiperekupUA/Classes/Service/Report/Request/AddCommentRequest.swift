//
//  AddCommentRequest.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 15.08.2021.
//

import Alamofire

struct AddCommentRequest: APIRequestBody {
    private let regNumber: String
    private let vin: String
    private let title: String
    private let text: String
    
    init(regNumber: String, vin: String, title: String, text: String) {
        self.regNumber = regNumber
        self.vin = vin
        self.title = title
        self.text = text
    }
    
    var url: String {
        GlobalDefinitions.domainUrl + "/api/ua/add_comment"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "reg_number": regNumber,
            "vin": vin,
            "title": title,
            "description": text
        ]
    }
    
    var headers: HTTPHeaders? {
        HTTPHeaders(defaultHeaders)
    }
    
    var encoding: ParameterEncoding {
        URLEncoding.default
    }
}

