//
//  OnboardingManagerCore.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 25.07.2021.
//

import Foundation
import RxSwift

final class OnboardingManagerCore: OnboardingManager {
    func completeOnboarding() -> Observable<Bool> {
        UserDefaults.standard.set(true, forKey: Constants.completeKey)
        return .just(UserDefaults.standard.bool(forKey: Constants.completeKey))
    }
    
    func onboardingIsCompleted() -> Observable<Bool> {
        .just(UserDefaults.standard.bool(forKey: Constants.completeKey))
    }
}

private extension OnboardingManagerCore {
    enum Constants {
        static let completeKey = "onboarding_manager_core_complete_key"
    }
}
