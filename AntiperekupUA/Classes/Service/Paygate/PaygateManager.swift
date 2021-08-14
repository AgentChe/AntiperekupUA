//
//  PaygateManager.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 05.08.2021.
//

import Foundation
import RxSwift

protocol PaygateManager {
    func isActiveSubscription() -> Single<Bool>
}
