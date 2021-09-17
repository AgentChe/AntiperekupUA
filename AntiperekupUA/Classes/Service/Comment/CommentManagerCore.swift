//
//  CommentManagerCore.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 16.09.2021.
//

import RxSwift

final class CommentManagerCore {
    func addComment(regNumber: String, vin: String, title: String, comment: String) -> Single<AddCommentModel?> {
        let request = AddCommentRequest(
            regNumber: regNumber,
            vin: vin,
            title: title,
            comment: comment
        )
        
        return RestAPITransport()
            .callServerApi(requestBody: request)
            .map { .init(from: $0) }
    }
}
