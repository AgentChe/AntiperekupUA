//
//  ReportErrorCell.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 12.08.2021.
//
import UIKit

final class ReportErrorCell: UITableViewCell {
    
    private lazy var icon = makeIcon()
    private lazy var label = makeTitle()
    private lazy var descriptionLabel = makeDescription()
    private lazy var stackView = makeStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ReportErrorCell {
    func setup(for errorMessage: String) {
        descriptionLabel.attributedText = errorMessage.attributed(with: .errorMessage)
        descriptionLabel.isHidden = errorMessage.isEmpty
    }
}

private extension ReportErrorCell {
    func initialize() {
        backgroundColor = .white
        contentView.backgroundColor = .white
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension ReportErrorCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            icon.heightAnchor.constraint(equalToConstant: 36.scale),
            icon.widthAnchor.constraint(equalTo: icon.heightAnchor),
            icon.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            icon.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10.scale)
        ])
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10.scale),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension ReportErrorCell {
    func makeIcon() -> UIImageView {
        let view = UIImageView()
        view.image = UIImage(named: "Report.Error")
        view.tintColor = UIColor(integralRed: 215, green: 87, blue: 72)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeTitle() -> UILabel {
        let text = TextAttributes()
            .font(UIFont.systemFont(ofSize: 14.scale))
            .lineHeight(17.scale)
            .textAlignment(.center)
            .textColor(UIColor(integralRed: 240, green: 134, blue: 129))
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.attributedText = "request_error".localized.attributed(with: text)
        view.numberOfLines = 1
        stackView.addArrangedSubview(view)
        return view
    }
    
    func makeDescription() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        stackView.addArrangedSubview(view)
        return view
    }
    
    func makeStackView() -> UIStackView {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 8.scale
        contentView.addSubview(view)
        return view
    }
}

private extension TextAttributes {
    static let errorMessage = TextAttributes()
        .font(UIFont.systemFont(ofSize: 11.scale))
        .lineHeight(18.scale)
        .textAlignment(.center)
        .textColor(UIColor(integralRed: 142, green: 143, blue: 142))
}
