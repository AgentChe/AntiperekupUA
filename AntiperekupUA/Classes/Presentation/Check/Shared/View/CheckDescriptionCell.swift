//
//  CheckDescriptionCell.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 17.09.2021.
//
import UIKit

final class CheckDescriptionCell: UITableViewCell {
    
    private lazy var descriptionLabel = makeLabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CheckDescriptionCell {
    func setup(for text: String) {
        descriptionLabel.attributedText = text.attributed(with: .title)
    }
}

private extension CheckDescriptionCell {
    func initialize() {
        backgroundColor = UIColor(integralRed: 242, green: 242, blue: 242)
        contentView.backgroundColor = UIColor(integralRed: 242, green: 242, blue: 242)
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension CheckDescriptionCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension CheckDescriptionCell {
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        contentView.addSubview(view)
        return view
    }
}

private extension TextAttributes {
    static let title = TextAttributes()
        .font(Fonts.SFProText.font(weight: .W400, size: 15.scale))
        .lineHeight(20.scale)
        .textColor(.black)
}
