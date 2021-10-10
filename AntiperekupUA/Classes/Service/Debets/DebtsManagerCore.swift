//
//  DebtsManagerCore.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 25.09.2021.
//

import RxSwift

final class DebtsManagerCore {
    func checkDebts(
        firstName: String,
        lastName: String,
        patronymic: String,
        dob: String,
        token: String,
        cookiesString: String
    ) -> Single<DebtsCheckModel?> {
        let request = DebtsCheckRequest(
            firstName: firstName,
            lastName: lastName,
            patronymic: patronymic,
            dob: dob,
            token: token,
            cookiesString: cookiesString
        )
        
        return RestAPITransport()
            .callServerApi(requestBody: request)
            .map(DebtsCheckModel.map(from:))
    }
}
