//
//  NewCommentThemeCell.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 13.09.2021.
//
import UIKit

final class NewCommentThemeCell: UITableViewCell {
    
    private lazy var detailLabel = makeDetailLabel()
    private lazy var chevron = makeChevron()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        initialize()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NewCommentThemeCell {
    func setup(for theme: NewCommentTheme) {
        textLabel?.attributedText = "new_comment_theme".localized.attributed(with: .title)
        detailLabel.attributedText = theme.name.attributed(with: .detail)
    }
}

private extension NewCommentThemeCell {
    func initialize() {
        backgroundColor = .white
        contentView.backgroundColor = .white
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension NewCommentThemeCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            detailLabel.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -11.scale),
            detailLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            chevron.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            chevron.centerYAnchor.constraint(equalTo: detailLabel.centerYAnchor),
            chevron.heightAnchor.constraint(equalToConstant: 12.scale),
            chevron.widthAnchor.constraint(equalToConstant: 7.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension NewCommentThemeCell {
    func makeDetailLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    func makeChevron() -> UIImageView {
        let view = UIImageView()
        view.image = UIImage(named: "Comment.Chevron")
        view.tintColor = UIColor(integralRed: 60, green: 60, blue: 67, alpha: 0.6)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}


private extension TextAttributes {
    static let title = TextAttributes()
        .font(Fonts.SFProText.font(weight: .W400, size: 17))
        .lineHeight(22.scale)
        .textColor(.black)
    
    static let detail = TextAttributes()
        .font(Fonts.SFProText.font(weight: .W400, size: 17))
        .lineHeight(22.scale)
        .textAlignment(.right)
        .textColor(UIColor(integralRed: 60, green: 60, blue: 67, alpha: 0.6))
}
