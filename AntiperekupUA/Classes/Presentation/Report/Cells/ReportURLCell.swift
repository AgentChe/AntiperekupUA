//
//  ReportURLCell.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 12.09.2021.
//

import UIKit

final class ReportURLCell: UITableViewCell {
    
    private lazy var separator = makeSeparator()
    private lazy var titleLabel = makeTitle()
    private lazy var valueLabel = makeValue()
    
    private var url: URL?
    private var didTapURL: ((URL?) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ReportURLCell {
    func setup(for title: String, value: String, didTapURL: @escaping ((URL?) -> Void)) {
        if !value.isEmpty {
            valueLabel.attributedText = value.attributed(with: .value)
        } else {
            valueLabel.attributedText = "no_data".localized.attributed(with: .value)
        }
        
        url = URL(string: value)
        self.didTapURL = didTapURL
        titleLabel.attributedText = title.attributed(with: .title)
    }
}

private extension ReportURLCell {
    func initialize() {
        backgroundColor = .white
        contentView.backgroundColor = .white
        selectionStyle = .none
    }
    
    @objc func didTapValue() {
        didTapURL?(url)
    }
}

// MARK: Make constraints
private extension ReportURLCell {
    func makeConstraints() {
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        valueLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        valueLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        NSLayoutConstraint.activate([
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1.scale)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: valueLabel.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8)
        ])
        
        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            valueLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 16),
            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
    }
}

// MARK: Lazy initialization
private extension ReportURLCell {
    func makeSeparator() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(integralRed: 246, green: 246, blue: 247)
        contentView.addSubview(view)
        return view
    }
    
    func makeTitle() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
        contentView.addSubview(view)
        return view
    }
    
    func makeValue() -> UILabel {
        let view = UILabel()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapValue))
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addGestureRecognizer(gesture)
        view.numberOfLines = 0
        contentView.addSubview(view)
        return view
    }
}

private extension TextAttributes {
    static let title = TextAttributes()
        .font(Fonts.SFProText.font(weight: .W400, size: 12.scale))
        .textColor(.black)
        .textAlignment(.left)
    
    static let value = TextAttributes()
        .font(Fonts.SFProText.font(weight: .W700, size: 12.scale))
        .textColor(.black)
        .textAlignment(.right)
    
    static let url = TextAttributes()
        .font(Fonts.SFProText.font(weight: .W700, size: 12.scale))
        .textColor(.black)
        .textAlignment(.right)
        .underlineStyle(.single)
}

