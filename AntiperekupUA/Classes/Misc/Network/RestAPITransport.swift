//
//  RestAPITransport.swift
//  BabyJournal
//
//  Created by Andrey Chernyshev on 11.12.2020.
//

import RxSwift
import Alamofire

final class RestAPITransport {
    func callServerApi(requestBody: APIRequestBody) -> Single<Any> {
        Single.create { single in
            let manager = Alamofire.Session.default
            manager.session.configuration.timeoutIntervalForRequest = 180
            
            let encodedUrl = requestBody.url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            
            let request = manager.request(encodedUrl,
                                          method: requestBody.method,
                                          parameters: requestBody.parameters,
                                          encoding: requestBody.encoding,
                                          headers: requestBody.headers)
                .validate(statusCode: [200, 201])
                .responseJSON(completionHandler: { response in
                    switch response.result {
                    case .success(let json):
                        single(.success(json))
                    case .failure(let error):
                        single(.failure(NetworkError(.serverNotAvailable, underlyingError: error)))
                    }
                })
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
}
