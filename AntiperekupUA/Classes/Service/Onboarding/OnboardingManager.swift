//
//  OnboardingManager.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 25.07.2021.
//

import Foundation
import RxSwift

protocol OnboardingManager: AnyObject {
    func completeOnboarding() -> Observable<Bool>
    func onboardingIsCompleted() -> Observable<Bool>
}
