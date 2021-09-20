//
//  PassportManagerCore.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 18.09.2021.
//

import RxSwift

final class PassportManagerCore {
    func checkPassport(series: String, number: String) -> Single<PassportCheckModel?> {
        let request = PassportCheckRequest(series: series, number: number)
        
        return RestAPITransport()
            .callServerApi(requestBody: request)
            .map(PassportCheckModel.map(from:))
    }
}
