//
//  ReportCheckCaptchaCell.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 16.10.2021.
//

import UIKit

final class ReportCheckCaptchaCell: UITableViewCell {
    
    private lazy var retryLabel = makeLabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ReportCheckCaptchaCell {
    func initialize() {
        backgroundColor = .white
        contentView.backgroundColor = .white
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension ReportCheckCaptchaCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            retryLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.scale),
            retryLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20.scale),
            retryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.scale),
            retryLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ReportCheckCaptchaCell {
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.attributedText = "mtsbu_check_captcha".localized.attributed(with: .title)
        contentView.addSubview(view)
        return view
    }
}


private extension TextAttributes {
    static let title = TextAttributes()
        .font(Fonts.SFProText.font(weight: .W700, size: 12.scale))
        .textColor(UIColor(integralRed: 112, green: 160, blue: 172))
        .textAlignment(.right)
}

