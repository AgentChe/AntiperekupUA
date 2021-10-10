//
//  DebetsCheckRecordCell.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 25.09.2021.
//
import UIKit

final class DebtsCheckRecordCell: UITableViewCell {
    
    private lazy var container = makeContainer()
    private lazy var lastNameLabel = makeFieldView()
    private lazy var firstNameLabel = makeFieldView()
    private lazy var middleNameLabel = makeFieldView()
    private lazy var deductionTypeLabel = makeFieldView()
    private lazy var birthdayLabel = makeFieldView()
    private lazy var departmentNameLabel = makeFieldView()
    private lazy var executorLabel = makeFieldView()
    private lazy var executorPhoneLabel = makeFieldView()
    private lazy var executorEmailLabel = makeFieldView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DebtsCheckRecordCell {
    func setup(for record: DebtsCheckModel.Record) {
        lastNameLabel.setup(for: "last_name".localized, value: record.lastName)
        firstNameLabel.setup(for: "name".localized, value: record.firstName)
        middleNameLabel.setup(for: "patronymic".localized, value: record.middleName)
        birthdayLabel.setup(for: "birthday".localized, value: record.birthday)
        deductionTypeLabel.setup(for: "deduction_type".localized, value: record.deductionType)
        departmentNameLabel.setup(for: "department_name".localized, value: record.departmentName)
        executorLabel.setup(for: "executor".localized, value: record.executor)
        executorPhoneLabel.setup(for: "executor_phone".localized, value: record.executorPhone)
        executorEmailLabel.setup(for: "executor_email".localized, value: record.executorEmail, isShowSeparator: false)
    }
}

private extension DebtsCheckRecordCell {
    func initialize() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension DebtsCheckRecordCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            lastNameLabel.topAnchor.constraint(equalTo: container.topAnchor),
            lastNameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            lastNameLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            firstNameLabel.topAnchor.constraint(equalTo: lastNameLabel.bottomAnchor),
            firstNameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            firstNameLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            middleNameLabel.topAnchor.constraint(equalTo: firstNameLabel.bottomAnchor),
            middleNameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            middleNameLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            birthdayLabel.topAnchor.constraint(equalTo: middleNameLabel.bottomAnchor),
            birthdayLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            birthdayLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            deductionTypeLabel.topAnchor.constraint(equalTo: birthdayLabel.bottomAnchor),
            deductionTypeLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            deductionTypeLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            departmentNameLabel.topAnchor.constraint(equalTo: deductionTypeLabel.bottomAnchor),
            departmentNameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            departmentNameLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            executorLabel.topAnchor.constraint(equalTo: departmentNameLabel.bottomAnchor),
            executorLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            executorLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            executorPhoneLabel.topAnchor.constraint(equalTo: executorLabel.bottomAnchor),
            executorPhoneLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            executorPhoneLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            executorEmailLabel.topAnchor.constraint(equalTo: executorPhoneLabel.bottomAnchor),
            executorEmailLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            executorEmailLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            executorEmailLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension DebtsCheckRecordCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1.scale
        view.layer.borderColor = UIColor(integralRed: 235, green: 235, blue: 235).cgColor
        view.layer.cornerRadius = 20.scale
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        contentView.addSubview(view)
        return view
    }
    
    func makeFieldView() -> CheckResultValueView {
        let view = CheckResultValueView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        container.addSubview(view)
        return view
    }
}

