//
//  ReportIconWithTextCell.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 12.08.2021.
//
import UIKit

final class ReportIconWithTextCell: UITableViewCell {
    
    private lazy var contentContainer = makeContentContainer()
    private lazy var icon = makeIcon()
    private lazy var label = makeTitle()
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

extension ReportIconWithTextCell {
    func setup(for model: ReportIconWithTextModel) {
        label.attributedText = model.text.attributed(with: .text.textColor(model.iconType.color))
        icon.tintColor = model.iconType.color
        icon.image = model.iconType.icon
        
    }
}

extension ReportIconWithTextCell: CornerCellContainer {}

private extension ReportIconWithTextCell {
    func initialize() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension ReportIconWithTextCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding)
        ])
        
        NSLayoutConstraint.activate([
            contentContainer.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16.scale),
            contentContainer.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10.scale),
            contentContainer.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 16.scale),
            contentContainer.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -16.scale),
            contentContainer.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            icon.heightAnchor.constraint(equalToConstant: 17.scale),
            icon.widthAnchor.constraint(equalTo: icon.heightAnchor),
            icon.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            icon.centerYAnchor.constraint(equalTo: label.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10.scale),
            label.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
            label.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension ReportIconWithTextCell {
    func makeContentContainer() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        containerView.addSubview(view)
        return view
    }
    
    func makeIcon() -> UIImageView {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(view)
        return view
    }
    
    func makeTitle() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        contentContainer.addSubview(view)
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
        .font(Fonts.SFProText.font(weight: .W600, size: 15.scale))
}

private extension ReportIconWithTextModel.IconType {
    var icon: UIImage? {
        switch self {
        case .success:
            return UIImage(named: "Report.Check")
        case .error:
            return UIImage(named: "Report.Warning")
        }
    }
    
    var color: UIColor {
        switch self {
        case .success:
            return UIColor(integralRed: 83, green: 165, blue: 102)
        case .error:
            return UIColor(integralRed: 240, green: 134, blue: 129)
        }
    }
}
