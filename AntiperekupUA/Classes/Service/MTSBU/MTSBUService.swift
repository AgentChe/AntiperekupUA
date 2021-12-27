//
//  MTSBUService.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 13.10.2021.
//

import Foundation
import RxSwift

final class MTSBUService {
    static let shared = MTSBUService()
    
    func set(model: MTSBUModel, for regNumber: String) {
        let model = MTSBUCacheModel(date: Date(), model: model)
        guard let encodedData = try? JSONEncoder().encode(model) else { return }
        var object = UserDefaults.standard.object(forKey: Constants.mtsbRecordsKey) as? [String: Data] ?? [:]
        object[regNumber] = encodedData
        UserDefaults.standard.set(object, forKey: Constants.mtsbRecordsKey)
    }
    
    func getCache(for regNumber: String) -> MTSBUModel? {
        guard
            let object = UserDefaults.standard.object(forKey: Constants.mtsbRecordsKey) as? [String: Data],
            let decodedData = object[regNumber],
            let model = try? JSONDecoder().decode(MTSBUCacheModel.self, from: decodedData)
        else {
            return nil
        }
        
        let current = Calendar.current
        let currentComponents = current.dateComponents([.day, .month, .year], from: Date())
        let cachedComponents = current.dateComponents([.day, .month, .year], from: model.date)
        
        guard
            currentComponents.month == cachedComponents.month,
            currentComponents.year == cachedComponents.year,
            let currentDay = currentComponents.day,
            let cachedDay = cachedComponents.day,
            currentDay <= cachedDay + 2
        else {
            resetCache(for: regNumber)
            return nil
        }
        
        return model.model
    }
    
    func getCookies() -> Single<MTSBUCookiesModel?> {
        let request = MTSBUCookiesRequest()
        
        return RestAPITransport()
            .callServerApi(requestBody: request)
            .map(MTSBUCookiesModel.init)
    }
    
    private func resetCache(for regNumber: String) {
        guard
            var object = UserDefaults.standard.object(forKey: Constants.mtsbRecordsKey) as? [String: Data]
        else {
            return
        }
        object.removeValue(forKey: regNumber)
        UserDefaults.standard.set(object, forKey: Constants.mtsbRecordsKey)
    }
}

private extension MTSBUService {
    enum Constants {
        static let mtsbRecordsKey = "mtsbu_service_records_key"
    }
}
