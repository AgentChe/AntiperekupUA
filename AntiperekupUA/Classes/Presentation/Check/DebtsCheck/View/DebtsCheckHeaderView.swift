//
//  DebtsCheckHeaderView.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 24.09.2021.
//
import UIKit
import RxSwift
import RxCocoa

final class DebtsCheckHeaderView: UIView {
    
    lazy var lastNameField = makeFieldView(placeholder: "last_name".localized)
    lazy var nameField = makeFieldView(placeholder: "name".localized)
    lazy var patronymicField = makeFieldView(placeholder: "patronymic".localized)
    lazy var birthdayField = makeFieldView(placeholder: "birthday".localized)
    lazy var checkButton = makeButton()
    private let dateFormatter = DateFieldFormatter()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DebtsCheckHeaderView {
    var fieldData: Signal<DebtsCheckFieldData> {
        let fieldData = Observable
            .combineLatest(
                nameField.field.rx.text,
                lastNameField.field.rx.text,
                patronymicField.field.rx.text,
                birthdayField.field.rx.text
            )
        
        return checkButton.rx.tap
            .withLatestFrom(fieldData)
            .map {
                DebtsCheckFieldData(
                    firstName: $0.0 ?? "",
                    lastName: $0.1 ?? "",
                    patronymic: $0.2 ?? "",
                    birthday: $0.3 ?? ""
                )
            }
            .asSignal(onErrorSignalWith: .empty())
    }
    
    var fieldsState: Binder<DebtsCheckFieldState> {
        Binder(self) { base, state in
            base.lastNameField.isError = state.lastState == .error
            base.nameField.isError = state.firstState == .error
            base.patronymicField.isError = state.patronymicState == .error
            base.birthdayField.isError = state.birthdayState == .error
        }
    }
}

private extension DebtsCheckHeaderView {
    func initialize() {
        backgroundColor = .clear
        birthdayField.field.keyboardType = .decimalPad
        birthdayField.field.delegate = dateFormatter
    }
}

// MARK: Make constraints
private extension DebtsCheckHeaderView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            lastNameField.topAnchor.constraint(equalTo: topAnchor, constant: 16.scale),
            lastNameField.leadingAnchor.constraint(equalTo: leadingAnchor),
            lastNameField.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            nameField.topAnchor.constraint(equalTo: lastNameField.bottomAnchor, constant: 16.scale),
            nameField.leadingAnchor.constraint(equalTo: leadingAnchor),
            nameField.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            patronymicField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 16.scale),
            patronymicField.leadingAnchor.constraint(equalTo: leadingAnchor),
            patronymicField.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            birthdayField.topAnchor.constraint(equalTo: patronymicField.bottomAnchor, constant: 16.scale),
            birthdayField.leadingAnchor.constraint(equalTo: leadingAnchor),
            birthdayField.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            checkButton.topAnchor.constraint(equalTo: birthdayField.bottomAnchor, constant: 24.scale),
            checkButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            checkButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            checkButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16.scale),
            checkButton.heightAnchor.constraint(equalToConstant: 48.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension DebtsCheckHeaderView {
    func makeFieldView(placeholder: String) -> CheckFieldView {
        let view = CheckFieldView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.field.placeholder = placeholder
        addSubview(view)
        return view
    }
    
    func makeButton() -> UIButton {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setAttributedTitle("check".localized.uppercased().attributed(with: .button), for: .normal)
        view.backgroundColor = UIColor(integralRed: 221, green: 226, blue: 235)
        view.layer.borderWidth = 1.scale
        view.layer.borderColor = UIColor(integralRed: 160, green: 179, blue: 204).cgColor
        view.layer.cornerRadius = 14.scale
        addSubview(view)
        return view
    }
}

private extension TextAttributes {
    static let button = TextAttributes()
        .font(Fonts.SFProDisplay.font(weight: .W400, size: 20.scale))
        .lineHeight(24.scale)
        .textColor(UIColor(integralRed: 40, green: 42, blue: 48))
}

