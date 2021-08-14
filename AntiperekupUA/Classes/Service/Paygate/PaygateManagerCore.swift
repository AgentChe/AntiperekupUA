//
//  PaygateManagerCore.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 05.08.2021.
//

import Foundation
import RxSwift

final class PaygateManagerCore: PaygateManager {
    func isActiveSubscription() -> Single<Bool> {
        let request = GetPaygateRequest(ssad: UIDevice.idfv ?? "")
        
        return RestAPITransport()
            .callServerApi(requestBody: request)
            .map(GetPaygateRequestMapper.map(from:))
    }
}
