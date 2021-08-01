//
//  SessionManager.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 24.07.2021.
//

import Foundation
import RxSwift

protocol SessionManager: AnyObject {
    var uuid: String { get }
    var sign: String { get }
    func updateToken() -> Single<UpdateTokenModel?>
}
