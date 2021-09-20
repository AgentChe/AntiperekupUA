//
//  PassportCheckResultCell.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 18.09.2021.
//
import UIKit

final class PassportCheckResultCell: UITableViewCell {
    
    private lazy var iconView = makeImageView()
    private lazy var messageLabel = makeLabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PassportCheckResultCell {
    func setup(for message: String, isError: Bool) {
        let color = isError
            ? UIColor(integralRed: 215, green: 87, blue: 72)
            : UIColor(integralRed: 83, green: 165, blue: 102)
        
        let icon = isError
            ? UIImage(named: "Passport.Error")
            : UIImage(named: "Passport.Success")
        
        iconView.tintColor = color
        iconView.image = icon
        messageLabel.attributedText = message.attributed(with: .message.textColor(color))
    }
}

private extension PassportCheckResultCell {
    func initialize() {
        backgroundColor = UIColor(integralRed: 242, green: 242, blue: 242)
        contentView.backgroundColor = UIColor(integralRed: 242, green: 242, blue: 242)
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension PassportCheckResultCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 36.scale),
            iconView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconView.heightAnchor.constraint(equalToConstant: 50.scale),
            iconView.widthAnchor.constraint(equalToConstant: 50.scale)
        ])
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 19.scale),
            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30.scale),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30.scale),
            messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension PassportCheckResultCell {
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        contentView.addSubview(view)
        return view
    }
}

private extension TextAttributes {
    static let message = TextAttributes()
        .font(Fonts.SFProText.font(weight: .W600, size: 16.scale))
        .lineHeight(19.scale)
        .textAlignment(.center)
}
