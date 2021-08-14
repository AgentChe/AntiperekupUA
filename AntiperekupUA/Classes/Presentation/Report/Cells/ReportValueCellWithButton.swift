//
//  ReportValueCellWithButton.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 07.08.2021.
//

import UIKit

final class ReportValueCellWithButton: UITableViewCell {
    
    private lazy var separator = makeSeparator()
    private lazy var titleLabel = makeTitle()
    private lazy var valueLabel = makeValue()
    private lazy var stackView = makeStackView()
    private lazy var actionLabel = makeActionLabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ReportValueCellWithButton {
    func setup(for model: ReportValueWithActionModel) {
        titleLabel.attributedText = model.title.attributed(with: .title)
        valueLabel.attributedText = model.value.attributed(with: .value)
        actionLabel.attributedText = model.actionTitle?.attributed(with: .button)
        valueLabel.isHidden = model.value.isEmpty
        actionLabel.isHidden = model.action == .none
    }
}

private extension ReportValueCellWithButton {
    func initialize() {
        backgroundColor = .white
        contentView.backgroundColor = .white
        selectionStyle = .none
    }
    
    @objc func didTapLabel() {
        
    }
}

// MARK: Make constraints
private extension ReportValueCellWithButton {
    func makeConstraints() {
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        stackView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        stackView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        NSLayoutConstraint.activate([
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1.scale)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.scale),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10.scale),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10.scale)
        ])
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.scale),
            stackView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 16.scale),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8.scale),
            stackView.bottomAnchor.constraint(equalTo: separator.topAnchor, constant: -10.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ReportValueCellWithButton {
    func makeSeparator() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(integralRed: 246, green: 246, blue: 247)
        contentView.addSubview(view)
        return view
    }
    
    func makeTitle() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
        contentView.addSubview(view)
        return view
    }
    
    func makeValue() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        stackView.addArrangedSubview(view)
        return view
    }
    
    func makeActionLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapLabel))
        view.addGestureRecognizer(gesture)
        stackView.addArrangedSubview(view)
        return view
    }
    
    func makeStackView() -> UIStackView {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 4.scale
        view.alignment = .trailing
        contentView.addSubview(view)
        return view
    }
}

private extension TextAttributes {
    static let title = TextAttributes()
        .font(UIFont.systemFont(ofSize: 12.scale))
        .textColor(.black)
        .textAlignment(.left)
    
    static let value = TextAttributes()
        .font(UIFont.systemFont(ofSize: 12.scale, weight: .bold))
        .textColor(.black)
        .textAlignment(.right)
    
    static let button = TextAttributes()
        .font(UIFont.systemFont(ofSize: 12.scale, weight: .bold))
        .textColor(UIColor(integralRed: 112, green: 160, blue: 172))
}

private extension ReportValueWithActionModel {
    var title: String {
        switch fieldType {
        case .vin:
            return  "gov_data_vin".localized
        case .regNumber:
            return "gov_data_regnumber".localized
        case .technicalPassport:
            return "tech_passport_number".localized
        }
    }
    
    var actionTitle: String? {
        switch action {
        case .change:
            switch fieldType {
            case .vin:
                return "check_vin".localized
            case .regNumber:
                return "check_gos_number".localized
            case .technicalPassport:
                return nil
            }
        case .add:
            switch fieldType {
            case .vin:
                return "enter_vin".localized
            case .regNumber:
                return "enter_gos_number".localized
            case .technicalPassport:
                return "enter_tech_passport".localized
            }
        case .none:
            return nil
        }
    }
}
