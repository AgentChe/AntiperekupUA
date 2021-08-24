//
//  ReportCommentActionCell.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 15.08.2021.
//
import UIKit

final class ReportCommentActionCell: UITableViewCell {
    
    private lazy var button = makeButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ReportCommentActionCell {
    func initialize() {
        backgroundColor = .white
        contentView.backgroundColor = .white
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension ReportCommentActionCell {
    func makeConstraints() {
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 19.scale),
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.scale),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20.scale),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ReportCommentActionCell {
    func makeButton() -> UIButton {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setAttributedTitle("new_comment_button".localized.attributed(with: .button), for: .normal)
        contentView.addSubview(view)
        return view
    }
}

private extension TextAttributes {
    static let button = TextAttributes()
        .font(Fonts.SFProText.font(weight: .W600, size: 14.scale))
        .lineHeight(16.scale)
        .textAlignment(.center)
        .textColor(UIColor(integralRed: 112, green: 160, blue: 172))
}
