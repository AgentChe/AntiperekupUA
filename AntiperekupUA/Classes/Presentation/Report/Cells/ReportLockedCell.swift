//
//  ReportLockedCell.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 16.08.2021.
//
import UIKit

final class ReportLockedCell: UITableViewCell {
    
    private lazy var container = makeContainer()
    private lazy var titleLabel = makeTitle()
    private lazy var icon = makeIcon()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ReportLockedCell {
    func setup(for title: String) {
        titleLabel.attributedText = title.attributed(with: .title)
    }
}

private extension ReportLockedCell {
    func initialize() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension ReportLockedCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4.scale),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            icon.heightAnchor.constraint(equalToConstant: 24.scale),
            icon.widthAnchor.constraint(equalTo: icon.heightAnchor),
            icon.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8.scale),
            icon.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12.scale),
            titleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12.scale),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8.scale),
            titleLabel.trailingAnchor.constraint(equalTo: icon.leadingAnchor, constant: -8.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ReportLockedCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1.scale
        view.layer.borderColor = UIColor(integralRed: 160, green: 179, blue: 204).cgColor
        view.layer.cornerRadius = 14.scale
        view.backgroundColor = UIColor(integralRed: 221, green: 226, blue: 235)
        contentView.addSubview(view)
        return view
    }
    
    func makeTitle() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeIcon() -> UIImageView {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = .black
        view.image = UIImage(named: "Report.Lock")
        container.addSubview(view)
        return view
    }
}

private extension TextAttributes {
    static let title = TextAttributes()
        .font(Fonts.SFProDisplay.font(weight: .W400, size: 18.scale))
        .textColor(.black)
        .textAlignment(.center)
}
