//
//  ReportIconWithTextCell.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 12.08.2021.
//
import UIKit

final class ReportIconWithTextCell: UITableViewCell {
    
    private lazy var container = makeContainer()
    private lazy var icon = makeIcon()
    private lazy var label = makeTitle()
    
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

private extension ReportIconWithTextCell {
    func initialize() {
        backgroundColor = .white
        contentView.backgroundColor = .white
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension ReportIconWithTextCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10.scale),
            container.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16.scale),
            container.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            icon.heightAnchor.constraint(equalToConstant: 17.scale),
            icon.widthAnchor.constraint(equalTo: icon.heightAnchor),
            icon.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            icon.centerYAnchor.constraint(equalTo: label.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10.scale),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension ReportIconWithTextCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        contentView.addSubview(view)
        return view
    }
    
    func makeIcon() -> UIImageView {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeTitle() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        container.addSubview(view)
        return view
    }
}

private extension TextAttributes {
    static let text = TextAttributes()
        .font(UIFont.systemFont(ofSize: 15.scale))
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
