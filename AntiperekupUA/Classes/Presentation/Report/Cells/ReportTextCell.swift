//
//  ReportTextCell.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 11.08.2021.
//
import UIKit

final class ReportTextCell: UITableViewCell {
    
    private lazy var label = makeLabel()
    lazy var containerView = makeContainer()
    
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

extension ReportTextCell: CornerCellContainer {}

private extension ReportTextCell {
    func initialize() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension ReportTextCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16.scale),
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8.scale),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10.scale),
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -14.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ReportTextCell {
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        containerView.addSubview(view)
        return view
    }
    
    func makeContainer() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        contentView.addSubview(view)
        return view
    }
}

private extension TextAttributes {
    static let text = TextAttributes()
        .font(Fonts.SFProText.font(weight: .W400, size: 11.scale))
        .lineHeight(18.scale)
        .textColor(UIColor(integralRed: 142, green: 143, blue: 142))
}
