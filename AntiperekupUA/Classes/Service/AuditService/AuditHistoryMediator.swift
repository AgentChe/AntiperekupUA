//
//  AuditHistoryMediator.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 23.09.2021.
//

import RxSwift
import RxCocoa

final class AuditHistoryMediator {
    static let shared = AuditHistoryMediator()
    
    
    private lazy var itemsChangeTrigger = PublishRelay<Void>()
}

extension AuditHistoryMediator {
    
    func itemsChange() {
        itemsChangeTrigger.accept(())
    }
}


extension AuditHistoryMediator {
    var rxItemsChange: Signal<Void> {
        itemsChangeTrigger.asSignal()
    }
}
