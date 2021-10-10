//
//  DebtsCheckRequest.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 25.09.2021.
//

import Alamofire

struct DebtsCheckRequest: APIRequestBody {
    private let firstName: String
    private let lastName: String
    private let patronymic: String
    private let dob: String
    private let token: String
    private let cookiesString: String
    
    init(firstName: String, lastName: String, patronymic: String, dob: String, token: String, cookiesString: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.patronymic = patronymic
        self.dob = dob
        self.token = token
        self.cookiesString = cookiesString
    }
    
    var url: String {
        GlobalDefinitions.domainUrl + "/api/ua/debtors_v2"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "firstname": firstName,
            "lastname": lastName,
            "patronymic": patronymic,
            "dob": dob,
            "token": token,
            "cookies": cookiesString
        ]
    }
    
    var headers: HTTPHeaders? {
        HTTPHeaders(defaultHeaders)
    }
    
    var encoding: ParameterEncoding {
        URLEncoding.default
    }
}
