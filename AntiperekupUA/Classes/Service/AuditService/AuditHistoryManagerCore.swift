//
//  AuditHistoryManagerCore.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 22.09.2021.
//

import Foundation
import RxSwift

final class AuditHistoryManagerCore {
    
    func save(model: AuditHistoryModel) {
        var elements = getAuditHistory()
        elements.append(model)
        save(models: elements)
    }
    
    func delete(by id: String) {
        var elements = getAuditHistory()
        elements.removeAll { $0.id == id }
        save(models: elements)
    }
    
    func deleteAll() {
        UserDefaults.standard.set(nil, forKey: Constants.historyKey)
    }
    
    func getAuditHistory() -> [AuditHistoryModel] {
        guard let decodedData = UserDefaults.standard.object(forKey: Constants.historyKey) as? Data else {
            return []
        }
        let elements = try? JSONDecoder().decode([AuditHistoryModel].self, from: decodedData)
        return elements ?? []
    }
    
    func getItem(by id: String) -> AuditHistoryModel? {
        getAuditHistory().first(where: { $0.id == id })
    }
    
    private func save(models: [AuditHistoryModel]) {
        guard let encodedData = try? JSONEncoder().encode(models) else {
            return
        }
        
        UserDefaults.standard.set(encodedData, forKey: Constants.historyKey)
        AuditHistoryMediator.shared.itemsChange()
    }
}

private extension AuditHistoryManagerCore {
    enum Constants {
        static let historyKey = "audit_history_manager_core_key"
    }
}
