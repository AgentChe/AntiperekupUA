//
//  PassportCheckRecordCell.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 19.09.2021.
//
import UIKit

final class PassportCheckRecordCell: UITableViewCell {
    
    private lazy var container = makeContainer()
    private lazy var idValue = makeFieldView()
    private lazy var ovdValue = makeFieldView()
    private lazy var seriesValue = makeFieldView()
    private lazy var numberValue = makeFieldView()
    private lazy var typeValue = makeFieldView()
    private lazy var statusValue = makeFieldView()
    private lazy var theftData = makeFieldView()
    private lazy var insertDate = makeFieldView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PassportCheckRecordCell {
    func setup(for record: PassportCheckModel.Record) {
        idValue.setup(for: "wanted_passport_id".localized, value: record.id)
        ovdValue.setup(for: "wanted_passport_ovd".localized, value: record.ovd)
        seriesValue.setup(for: "wanted_passport_series".localized, value: record.series)
        numberValue.setup(for: "wanted_passport_number".localized, value: record.number)
        typeValue.setup(for: "wanted_passport_type".localized, value: record.type)
        statusValue.setup(for: "wanted_passport_status".localized, value: record.status)
        theftData.setup(for: "wanted_passport_theft_date".localized, value: record.theftDate)
        insertDate.setup(for: "wanted_passport_insert_date".localized, value: record.insertDate, isShowSeparator: false)
    }
}

private extension PassportCheckRecordCell {
    func initialize() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension PassportCheckRecordCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            idValue.topAnchor.constraint(equalTo: container.topAnchor),
            idValue.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            idValue.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            ovdValue.topAnchor.constraint(equalTo: idValue.bottomAnchor),
            ovdValue.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            ovdValue.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            seriesValue.topAnchor.constraint(equalTo: ovdValue.bottomAnchor),
            seriesValue.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            seriesValue.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            numberValue.topAnchor.constraint(equalTo: seriesValue.bottomAnchor),
            numberValue.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            numberValue.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            typeValue.topAnchor.constraint(equalTo: numberValue.bottomAnchor),
            typeValue.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            typeValue.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            statusValue.topAnchor.constraint(equalTo: typeValue.bottomAnchor),
            statusValue.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            statusValue.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            theftData.topAnchor.constraint(equalTo: statusValue.bottomAnchor),
            theftData.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            theftData.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            insertDate.topAnchor.constraint(equalTo: theftData.bottomAnchor),
            insertDate.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            insertDate.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            insertDate.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension PassportCheckRecordCell {
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
