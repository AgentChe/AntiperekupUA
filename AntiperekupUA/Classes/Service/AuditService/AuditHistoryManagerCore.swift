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
        var elements = getCahchedHistory()
        elements.remove(model)
        elements.insert(model)
        save(models: elements)
    }
    
    func getHistory() -> [History] {
        let result = getCahchedHistory()
        return result.sorted(by: { $0.date.compare($1.date) == .orderedDescending })
    }
    
    func delete(by id: String) {
        var elements = getCahchedHistory()
        guard let element = elements.first(where: { $0.id == id }) else {
            return
        }
        elements.remove(element)
        save(models: elements)
    }
    
    func getItem(by id: String) -> History? {
        getCahchedHistory().first(where: { $0.id == id })
    }
    
    private func getCahchedHistory() -> Set<History> {
        guard let decodedData = UserDefaults.standard.object(forKey: Constants.historyKey) as? Data else {
            return []
        }
        
        let elements = try? JSONDecoder().decode(Set<History>.self, from: decodedData)
        return elements ?? []
    }
    
    private func save(models: Set<History>) {
        guard let encodedData = try? JSONEncoder().encode(models) else {
            return
        }
        
        UserDefaults.standard.set(encodedData, forKey: Constants.historyKey)
        AuditHistoryMediator.shared.itemsChange()
    }
    
    func deleteAll() {
        UserDefaults.standard.set(nil, forKey: Constants.historyKey)
        AuditHistoryMediator.shared.itemsChange()
    }
}

private extension AuditHistoryManagerCore {
    enum Constants {
        static let historyKey = "audit_history_manager_core_key"
    }
}
