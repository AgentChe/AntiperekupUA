//
//  PassportCheckFieldState.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 19.09.2021.
//

import Foundation

struct PassportCheckFieldState {
    let seriesState: State
    let series: String
    let numberState: State
    let number: String
 
    enum State {
        case initial
        case error
    }
}
