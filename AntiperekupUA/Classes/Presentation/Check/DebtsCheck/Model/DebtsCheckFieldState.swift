//
//  DebtsCheckFieldState.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 26.09.2021.
//

import Foundation

struct DebtsCheckFieldState {
    let firstState: State
    let lastState: State
    let patronymicState: State
    let birthdayState: State
    let fieldsData: DebtsCheckFieldData
    
    enum State {
        case initial
        case error
    }
}

extension DebtsCheckFieldState {
    var isValid: Bool {
        [firstState, lastState, patronymicState, birthdayState].allSatisfy { $0 == .initial }
    }
}


