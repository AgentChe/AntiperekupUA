//
//  ReportAlertScreenView.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 24.08.2021.
//
import UIKit

extension ReportAlertScreenView {
    enum FieldType {
        case regNumber
        case vin
        case tecnicalPassport
    }
}

final class ReportAlertScreenView: UIView {
    
    private lazy var titleLabel = makeTitle()
    lazy var textField = makeTextField()
    lazy var confirmButton = makeConfirmButton()
    lazy var closeButton = makeCloseButton()
    private lazy var stackView = makeStackView()
    private lazy var errorLabel = makeErrorLabel()
    private lazy var containerView = makeContainer()
    
    private var fieldType: FieldType?
    
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
    func setup(title: String, defaultValue: String, fieldType: FieldType) {
        titleLabel.attributedText = title.attributed(with: .title)
        textField.text = defaultValue
        textField.placeholder = fieldType.placeholder
        self.fieldType = fieldType
    }
    
    func showError(message: String) {
        errorLabel.isHidden = message.isEmpty
        errorLabel.text = message
    }
}

extension ReportAlertScreenView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var fieldType: SearchValueFormatter.FieldType? {
            switch self.fieldType {
            case .regNumber:
                return .regNumber
            case .vin:
                return .vin
            case .tecnicalPassport:
                return .technicalPassport
            case .none:
                return nil
            }
        }
        return SearchValueFormatter.textField(textField, shouldChangeCharactersIn: range, replacementString: string, fieldType: fieldType)
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
        view.delegate = self
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

private extension ReportAlertScreenView.FieldType {
    var placeholder: String {
        switch self {
        case .regNumber:
            return "АА1234ТС"
        case .vin:
            return "XTA210990W2395414"
        case .tecnicalPassport:
            return "CXI 399999"
        }
    }
    
    var maxLength: Int {
        switch self {
        case .regNumber:
            return 9
        case .vin:
            return 17
        case .tecnicalPassport:
            return 9
        }
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
