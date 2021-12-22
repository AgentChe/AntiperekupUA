//
//  AuditHistoryManagerCore.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 22.09.2021.
//

import Foundation
import RxSwift

private extension History {
    var id: String {
        switch self {
        case let .report(model):
            return model.id
        case let .passport(model):
            return model.id
        case let .debts(model):
            return model.id
        }
    }
    
    var date: Date {
        switch self {
        case let .report(model):
            return model.date
        case let .passport(model):
            return model.date
        case let .debts(model):
            return model.date
        }
    }
}

final class AuditHistoryManagerCore {
    
    func save(model: History) {
        var elements = getHistory()
        elements.append(model)
        save(models: elements)
    }
    
    func getHistory() -> [History] {
        guard let decodedData = UserDefaults.standard.object(forKey: Constants.historyKey) as? Data else {
            return []
        }
        let elements = try? JSONDecoder().decode([History].self, from: decodedData)
        let result = elements ?? []
        return result.sorted(by: { $0.date.compare($1.date) == .orderedDescending })
    }
    
    func delete(by id: String) {
        var elements = getHistory()
        elements.removeAll { $0.id == id }
        save(models: elements)
    }
    
    func getItem(by id: String) -> History? {
        getHistory().first(where: { $0.id == id })
    }
    
    private func save(models: [History]) {
        guard let encodedData = try? JSONEncoder().encode(models) else {
            return
        }
        
        UserDefaults.standard.set(encodedData, forKey: Constants.historyKey)
        AuditHistoryMediator.shared.itemsChange()
    }
    //=======================
//    func save(model: AuditHistoryModel) {
//        var elements = getAuditHistory()
//        elements.append(model)
//        save(models: elements)
//    }
    
//    func delete(by id: String) {
//        var elements = getAuditHistory()
//        elements.removeAll { $0.id == id }
//        save(models: elements)
//    }
    
    func deleteAll() {
        UserDefaults.standard.set(nil, forKey: Constants.historyKey)
        AuditHistoryMediator.shared.itemsChange()
    }
    
//    func getAuditHistory() -> [AuditHistoryModel] {
//        guard let decodedData = UserDefaults.standard.object(forKey: Constants.historyKey) as? Data else {
//            return []
//        }
//        let elements = try? JSONDecoder().decode([AuditHistoryModel].self, from: decodedData)
//        let result = elements ?? []
//        return result.sorted(by: { $0.date.compare($1.date) == .orderedDescending })
//    }
    
//    func getItem(by id: String) -> AuditHistoryModel? {
//        getAuditHistory().first(where: { $0.id == id })
//    }
    
//    private func save(models: [AuditHistoryModel]) {
//        guard let encodedData = try? JSONEncoder().encode(models) else {
//            return
//        }
//
//        UserDefaults.standard.set(encodedData, forKey: Constants.historyKey)
//        AuditHistoryMediator.shared.itemsChange()
//    }
}

private extension AuditHistoryManagerCore {
    enum Constants {
        static let historyKey = "audit_history_manager_core_key"
    }
}
