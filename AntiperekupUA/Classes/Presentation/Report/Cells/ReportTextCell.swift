//
//  ReportTextCell.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 11.08.2021.
//
import UIKit

final class ReportTextCell: UITableViewCell {
    
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

extension ReportTextCell {
    func setup(for text: String) {
        label.attributedText = text.attributed(with: .text)
    }
}

private extension ReportTextCell {
    func initialize() {
        backgroundColor = .white
        contentView.backgroundColor = .white
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension ReportTextCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.scale),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8.scale),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10.scale),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ReportTextCell {
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        contentView.addSubview(view)
        return view
    }
}

private extension TextAttributes {
    static let text = TextAttributes()
        .font(UIFont.systemFont(ofSize: 11.scale, weight: .regular))
        .lineHeight(18.scale)
        .textColor(UIColor(integralRed: 142, green: 143, blue: 142))
}
