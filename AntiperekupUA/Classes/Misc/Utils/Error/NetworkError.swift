//
//  NetworkError.swift
//  BabyJournal
//
//  Created by Andrey Chernyshev on 11.12.2020.
//

struct NetworkError: Error {
    enum Code {
        case serverNotAvailable
    }

    let code: Code
    let underlyingError: Error?

    init(_ code: Code, underlyingError: Error? = nil) {
        self.code = code
        self.underlyingError = underlyingError
    }
}
