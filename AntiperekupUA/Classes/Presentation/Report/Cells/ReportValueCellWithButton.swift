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
    lazy var containerView = makeContainer()
    
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

extension ReportValueCellWithButton: CornerCellContainer {}

private extension ReportValueCellWithButton {
    func initialize() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
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
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding)
        ])
        
        NSLayoutConstraint.activate([
            separator.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1.scale)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16.scale),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -10.scale),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10.scale)
        ])
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16.scale),
            stackView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 16.scale),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8.scale),
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
        containerView.addSubview(view)
        return view
    }
    
    func makeTitle() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
        containerView.addSubview(view)
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
        containerView.addSubview(view)
        return view
    }
    
    func makeContainer() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        contentView.addSubview(view)
        return view
    }
}

private extension TextAttributes {
    static let title = TextAttributes()
        .font(Fonts.SFProText.font(weight: .W400, size: 12.scale))
        .textColor(.black)
        .textAlignment(.left)
    
    static let value = TextAttributes()
        .font(Fonts.SFProText.font(weight: .W700, size: 12.scale))
        .textColor(.black)
        .textAlignment(.right)
    
    static let button = TextAttributes()
        .font(Fonts.SFProText.font(weight: .W700, size: 12.scale))
        .textColor(UIColor(integralRed: 112, green: 160, blue: 172))
}

private extension ReportValueWithActionModel {
    var title: String {
        switch fieldType {
        case .vin:
            return "gov_data_vin".localized
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
