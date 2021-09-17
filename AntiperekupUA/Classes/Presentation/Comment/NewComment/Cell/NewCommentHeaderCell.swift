//
//  NewCommentHeaderCell.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 15.09.2021.
//
import UIKit

final class NewCommentHeaderCell: UITableViewCell {
    
    private lazy var title = makeTitle()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NewCommentHeaderCell {
    func setup(for header: String) {
        title.attributedText = header.attributed(with: .title)
    }
}

private extension NewCommentHeaderCell {
    func initialize() {
        backgroundColor = UIColor(integralRed: 242, green: 242, blue: 242)
        contentView.backgroundColor = UIColor(integralRed: 242, green: 242, blue: 242)
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension NewCommentHeaderCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12.scale),
            title.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12.scale),
            title.topAnchor.constraint(equalTo: topAnchor, constant: 18.scale),
            title.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension NewCommentHeaderCell {
    func makeTitle() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}

private extension TextAttributes {
    static let title = TextAttributes()
        .font(Fonts.SFProText.font(weight: .W400, size: 13.scale))
        .lineHeight(18.scale)
        .textColor(UIColor(integralRed: 60, green: 60, blue: 67, alpha: 0.6))
}
