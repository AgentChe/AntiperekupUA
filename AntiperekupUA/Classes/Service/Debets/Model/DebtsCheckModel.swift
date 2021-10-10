//
//  DebtsCheckModel.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 25.09.2021.
//

import Foundation

struct DebtsCheckModel {
    let result: Bool
    let errorMessage: String
    let records: [Record]
    
    struct Record {
        let lastName: String
        let firstName: String
        let middleName: String
        let deductionType: String
        let birthday: String
        let departmentName: String
        let departmentPhone: String
        let executor: String
        let executorPhone: String
        let executorEmail: String
    }
}

extension DebtsCheckModel {
    static func map(from response: Any) -> DebtsCheckModel? {
        guard
            let json = response as? [String: Any],
            let data = json["data"] as? [String: Any],
            let result = data["result"] as? Bool,
            let errorMessage = data["error_message"] as? String
        else {
            return nil
        }
        
        let records = data["data"] as? [[String: Any]] ?? []
        
        return DebtsCheckModel(
            result: result,
            errorMessage: errorMessage,
            records: records.compactMap { .init(from: $0) }
        )
    }
}

private extension DebtsCheckModel.Record {
    init?(from response: [String: Any]) {
        guard
            let lastName = response["last_name"] as? String,
            let firstName = response["first_name"] as? String,
            let middleName = response["middle_name"] as? String,
            let deductionType = response["deduction_type"] as? String,
            let birthday = response["birthdate"] as? String,
            let departmentName = response["department_name"] as? String,
            let departmentPhone = response["department_phone"] as? String,
            let executor = response["executor"] as? String,
            let executorPhone = response["executor_phone"] as? String,
            let executorEmail = response["executor_email"] as? String
        else {
            return nil
        }
        
        self.lastName = lastName
        self.firstName = firstName
        self.middleName = middleName
        self.deductionType = deductionType
        self.birthday = birthday
        self.departmentName = departmentName
        self.departmentPhone = departmentPhone
        self.executor = executor
        self.executorPhone = executorPhone
        self.executorEmail = executorEmail
    }
}

extension DebtsCheckModel.Record: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(lastName)
        hasher.combine(firstName)
        hasher.combine(middleName)
        hasher.combine(birthday)
    }
}
