//
//  ComplainCommentRequest.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 15.08.2021.
//

import Alamofire

struct ComplainCommentRequest: APIRequestBody {
    private let commentId: Int
    
    init(commentId: Int) {
        self.commentId = commentId
    }
    
    var url: String {
        GlobalDefinitions.domainUrl + "/api/ua/complain"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "comment_id": commentId
        ]
    }
    
    var headers: HTTPHeaders? {
        HTTPHeaders(defaultHeaders)
    }
    
    var encoding: ParameterEncoding {
        URLEncoding.default
    }
}
