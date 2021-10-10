//
//  PassportCheckHeaderView.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 18.09.2021.
//
import UIKit
import RxSwift
import RxCocoa

final class PassportCheckHeaderView: UIView {
    
    lazy var seriesField = makeFieldView(placeholder: "wanted_passport_series_hint".localized)
    lazy var numberField = makeFieldView(placeholder: "wanted_passport_number_hint".localized)
    lazy var checkButton = makeButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PassportCheckHeaderView {
    var fieldData: Signal<(series: String, number: String)> {
        let fieldData = Observable
            .combineLatest(
                seriesField.field.rx.text,
                numberField.field.rx.text
            )
        
        return checkButton.rx.tap
            .withLatestFrom(fieldData)
            .map { (series: $0.0 ?? "", number: $0.1 ?? "") }
            .asSignal(onErrorSignalWith: .empty())
    }
    
    var fieldsState: Binder<PassportCheckFieldState> {
        Binder(self) { base, state in
            base.seriesField.isError = state.seriesState == .error
            base.numberField.isError = state.numberState == .error
        }
    }
}

private extension PassportCheckHeaderView {
    func initialize() {
        backgroundColor = .clear
        seriesField.field.keyboardType = .asciiCapable
        numberField.field.keyboardType = .decimalPad
    }
}

// MARK: Make constraints
private extension PassportCheckHeaderView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            seriesField.topAnchor.constraint(equalTo: topAnchor, constant: 16.scale),
            seriesField.leadingAnchor.constraint(equalTo: leadingAnchor),
            seriesField.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            numberField.topAnchor.constraint(equalTo: seriesField.bottomAnchor, constant: 16.scale),
            numberField.leadingAnchor.constraint(equalTo: leadingAnchor),
            numberField.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            checkButton.topAnchor.constraint(equalTo: numberField.bottomAnchor, constant: 24.scale),
            checkButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            checkButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            checkButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16.scale),
            checkButton.heightAnchor.constraint(equalToConstant: 48.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension PassportCheckHeaderView {
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
