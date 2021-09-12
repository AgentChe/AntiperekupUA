//
//  PhotoModel.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 14.08.2021.
//

import Foundation

struct PhotoModel {
    let result: Bool
    let errorMessage: String
    let photos: [Photo]
    
    struct Photo {
        let make: String
        let model: String
        let date: String
        let regNumber: String
        let url: URL?
    }
}

extension PhotoModel {
    static func map(from response: Any) -> PhotoModel? {
        guard
            let json = response as? [String: Any],
            let data = json["data"] as? [String: Any],
            let result = data["result"] as? Bool,
            let errorMessage = data["error_message"] as? String
        else {
            return nil
        }
        
        let photos = data["photos"] as? [[String: Any]] ?? []
        
        return PhotoModel(
            result: result,
            errorMessage: errorMessage,
            photos: photos.map { .init(from: $0) }
        )
    }
}

private extension PhotoModel.Photo {
    init(from response: [String: Any]) {
        make = response["make"] as? String ?? ""
        model = response["model"] as? String ?? ""
        date = response["date"] as? String ?? ""
        regNumber = response["gosnumber"] as? String ?? ""
        url = (response["photo_url"] as? String).flatMap { URL(string: $0) }
    }
}
