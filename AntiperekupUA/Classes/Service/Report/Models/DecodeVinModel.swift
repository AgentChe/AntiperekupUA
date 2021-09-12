//
//  DecodeVinModel.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 31.08.2021.
//

import Foundation

struct DecodeVinModel {
    let result: Bool
    let errorMessage: String
    let records: [Record]
    
    enum Record {
        case title(String)
        case value(title: String, value: String)
        case logo(URL)
        
        var isLogo: Bool {
            switch self {
            case .logo:
                return true
            default:
                return false
            }
        }
        
        var logoURL: URL? {
            switch self {
            case let .logo(url):
                return url
            default:
                return nil
            }
        }
    }
}

extension DecodeVinModel {
    static func map(from response: Any) -> DecodeVinModel? {
        guard
            let json = response as? [String: Any],
            let data = json["data"] as? [String: Any],
            let result = data["result"] as? Bool,
            let errorMessage = data["error_message"] as? String
        else {
            return nil
        }
        
        let records = data["decoder"] as? [[String: Any]] ?? []
        
        return DecodeVinModel(
            result: result,
            errorMessage: errorMessage,
            records: records.compactMap { .init(from: $0)}
        )
    }
}

extension DecodeVinModel.Record {
    init?(from response: [String: Any]) {
        guard let title = response["title"] as? String else {
            let url = (response["logo"] as? String).flatMap { URL(string: $0) }
            
            if let logoURL = url {
                self = .logo(logoURL)
            } else {
                return nil
            }
            return
        }
        
        if let data = response["data"] as? String {
            guard !data.isEmpty else {
                return nil
            }
            self = .value(title: title, value: data)
        } else {
            self = .title(title)
        }
    }
}
