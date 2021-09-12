//
//  ReportCommentActionCell.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 15.08.2021.
//
import UIKit

final class ReportCommentActionCell: UITableViewCell {
    
    private lazy var label = makeLabel()
    
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
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 19.scale),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.scale),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20.scale),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ReportCommentActionCell {
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        view.attributedText = "new_comment_button".localized.attributed(with: .button)
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
