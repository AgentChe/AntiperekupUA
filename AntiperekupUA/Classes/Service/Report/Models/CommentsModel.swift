//
//  CommentsModel.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 15.08.2021.
//

import Foundation

struct CommentsModel {
    let result: Bool
    let errorMessage: String
    let comments: [Comment]
    
    struct Comment {
        let id: Int
        let vin: String
        let gosNumber: String
        let timestamp: Int
        let title: String
        let text: String
    }
}

extension CommentsModel {
    static func map(from response: Any) -> CommentsModel? {
        guard
            let json = response as? [String: Any],
            let data = json["data"] as? [String: Any],
            let result = data["result"] as? Bool,
            let errorMessage = data["error_message"] as? String
        else {
            return nil
        }
        
        let comments = data["comments"] as? [[String: Any]] ?? []
        
        return CommentsModel(
            result: result,
            errorMessage: errorMessage,
            comments: comments.map { .init(from: $0) }
        )
    }
}

private extension CommentsModel.Comment {
    init(from response: [String: Any]) {
        id = response["id"] as? Int ?? 0
        vin = response["vin"] as? String ?? ""
        gosNumber = response["gosnumber"] as? String ?? ""
        timestamp = response["timestamp"] as? Int ?? 0
        title = response["title"] as? String ?? ""
        text = response["description"] as? String ?? ""
    }
}
