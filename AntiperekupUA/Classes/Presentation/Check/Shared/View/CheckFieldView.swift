//
//  CheckFieldView.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 17.09.2021.
//
import UIKit

final class CheckFieldView: UIView {
    
    lazy var field = makeTextField()
    
    var isError: Bool = false {
        didSet {
            let color = isError
                ? UIColor(integralRed: 205, green: 47, blue: 30)
                : UIColor(integralRed: 160, green: 179, blue: 204)
            
            layer.borderColor = color.cgColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        intialize()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension CheckFieldView {
    func intialize() {
        backgroundColor = UIColor(integralRed: 237, green: 239, blue: 241)
        layer.borderWidth = 1.scale
        isError = false
        layer.cornerRadius = 14.scale
    }
}

// MARK: Make constraints
private extension CheckFieldView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            field.topAnchor.constraint(equalTo: topAnchor, constant: 14.scale),
            field.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14.scale),
            field.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            field.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension CheckFieldView {
    func makeTextField() -> UITextField {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.overrideUserInterfaceStyle = .light
        addSubview(view)
        return view
    }
}
