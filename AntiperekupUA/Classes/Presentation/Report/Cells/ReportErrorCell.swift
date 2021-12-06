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

extension ReportErrorCell {
    func setup(for errorMessage: String) {
        label.attributedText = "request_error".localized.attributed(with: .title)
        descriptionLabel.attributedText = errorMessage.attributed(with: .errorMessage)
        descriptionLabel.isHidden = errorMessage.isEmpty
    }
}

extension ReportErrorCell: CornerCellContainer {}

private extension ReportErrorCell {
    func initialize() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension ReportErrorCell {
    func makeConstraints() {
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            icon.heightAnchor.constraint(equalToConstant: 36.scale),
            icon.widthAnchor.constraint(equalTo: icon.heightAnchor),
            icon.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            icon.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10.scale)
        ])
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 10.scale),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16.scale),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16.scale),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -13.scale)
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
        containerView.addSubview(view)
        return view
    }
    
    func makeTitle() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
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
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 8.scale
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
    static let errorMessage = TextAttributes()
        .font(Fonts.SFProText.font(weight: .W400, size: 11.scale))
        .lineHeight(18.scale)
        .textAlignment(.center)
        .textColor(UIColor(integralRed: 142, green: 143, blue: 142))
    
    static let title = TextAttributes()
        .font(Fonts.SFProText.font(weight: .W600, size: 14.scale))
        .lineHeight(17.scale)
        .textAlignment(.center)
        .textColor(UIColor(integralRed: 240, green: 134, blue: 129))
}
