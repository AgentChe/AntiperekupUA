//
//  ReportDescriptionCell.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 17.08.2021.
//
import UIKit

final class ReportDescriptionCell: UITableViewCell {
    
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

extension ReportDescriptionCell {
    func setup(for text: String) {
        label.attributedText = text.attributed(with: .description)
    }
}

private extension ReportDescriptionCell {
    func initialize() {
        backgroundColor = .white
        contentView.backgroundColor = .white
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension ReportDescriptionCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.scale),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.scale),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20.scale),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ReportDescriptionCell {
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        contentView.addSubview(view)
        return view
    }
}

private extension TextAttributes {
    static let description = TextAttributes()
        .font(Fonts.SFProText.font(weight: .W400, size: 13.scale))
        .lineHeight(20.scale)
        .textColor(.black)
        .textAlignment(.left)
}
