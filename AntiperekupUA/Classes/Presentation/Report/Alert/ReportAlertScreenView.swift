//
//  ReportAlertScreenView.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 24.08.2021.
//
import UIKit

final class ReportAlertScreenView: UIView {
    
    private lazy var titleLabel = makeTitle()
    lazy var textField = makeTextField()
    lazy var confirmButton = makeConfirmButton()
    lazy var closeButton = makeCloseButton()
    private lazy var stackView = makeStackView()
    private lazy var errorLabel = makeErrorLabel()
    private lazy var containerView = makeContainer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ReportAlertScreenView {
    func setup(title: String, defaultValue: String, placeholder: String) {
        titleLabel.attributedText = title.attributed(with: .title)
        textField.text = defaultValue
        textField.placeholder = placeholder
    }
    
    func showError(message: String) {
        errorLabel.isHidden = message.isEmpty
        errorLabel.text = message
    }
}

private extension ReportAlertScreenView {
    func initialize() {
        backgroundColor = .white
        stackView.addArrangedSubview(containerView)
        stackView.addArrangedSubview(errorLabel)
    }
}

// MARK: Make constraints
private extension ReportAlertScreenView {
    func makeConstraints() {
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20.scale),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10.scale),
            textField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10.scale),
            textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10.scale),
            textField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10.scale)
        ])
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10.scale),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            confirmButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10.scale),
            confirmButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            confirmButton.widthAnchor.constraint(equalToConstant: 140.scale),
            confirmButton.heightAnchor.constraint(equalToConstant: 30.scale)
        ])
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: confirmButton.bottomAnchor, constant: 10.scale),
            closeButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 140.scale),
            closeButton.heightAnchor.constraint(equalToConstant: 30.scale),
            closeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ReportAlertScreenView {
    func makeTitle() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        addSubview(view)
        return view
    }
    
    func makeStackView() -> UIStackView {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 10.scale
        addSubview(view)
        return view
    }
    
    func makeContainer() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 10.scale
        view.layer.borderWidth = 0.5.scale
        view.layer.borderColor = UIColor(integralRed: 125, green: 172, blue: 221).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    func makeErrorLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        view.font = Fonts.SFProText.font(weight: .W400, size: 12.scale)
        view.isHidden = true
        view.textColor = UIColor(integralRed: 205, green: 47, blue: 30)
        return view
    }
    
    func makeTextField() -> UITextField {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .black
        view.overrideUserInterfaceStyle = .light
        view.backgroundColor = .clear
        view.autocapitalizationType = .allCharacters
        containerView.addSubview(view)
        return view
    }
    
    func makeCloseButton() -> UIButton {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setAttributedTitle("close".localized.attributed(with: .close), for: .normal)
        addSubview(view)
        return view
    }
    
    func makeConfirmButton() -> UIButton {
        let view = UIButton()
        view.setAttributedTitle("confirm".localized.attributed(with: .confirm), for: .normal)
        view.backgroundColor = UIColor(integralRed: 0, green: 91, blue: 187)
        view.layer.cornerRadius = 15.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}

private extension TextAttributes {
    static let title = TextAttributes()
        .font(Fonts.SFProText.font(weight: .W400, size: 14.scale))
        .textColor(.black)
        .textAlignment(.center)
    
    static let confirm = TextAttributes()
        .font(Fonts.SFProText.font(weight: .W500, size: 14.scale))
        .textColor(.white)
        .textAlignment(.center)
    
    static let close = TextAttributes()
        .font(Fonts.SFProText.font(weight: .W500, size: 14.scale))
        .textColor(.black)
        .textAlignment(.center)
}
