//
//  MainActionCell.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 31.07.2021.
//

import UIKit

class MainActionCell: UITableViewCell {
    private lazy var containerView = makeContainer()
    private lazy var contentContainer = makeContentContainer()
    private lazy var iconView = makeImageView()
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

extension MainActionCell {
    func setup(for action: MainTableAction) {
        iconView.image = action.image
        label.attributedText = action.title.attributed(with: .title)
    }
}

private extension MainActionCell {
    func initialize() {
        contentView.backgroundColor = .white
        backgroundColor = .white
        selectionStyle = .none
    }
}

private extension MainActionCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.scale),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            containerView.heightAnchor.constraint(equalToConstant: 50.scale)
        ])
        
        NSLayoutConstraint.activate([
            contentContainer.topAnchor.constraint(equalTo: containerView.topAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            contentContainer.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: contentContainer.topAnchor, constant: 8.scale),
            iconView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor, constant: -8.scale),
            iconView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            iconView.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentContainer.topAnchor, constant: 15.scale),
            label.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor, constant: -15.scale),
            label.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor)
        ])
    }
}

private extension MainActionCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(integralRed: 229, green: 239, blue: 248)
        view.layer.cornerRadius = 10.scale
        view.layer.borderWidth = 0.5.scale
        view.layer.borderColor = UIColor(integralRed: 125, green: 172, blue: 221).cgColor
        contentView.addSubview(view)
        return view
    }
    
    func makeContentContainer() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        containerView.addSubview(view)
        return view
    }
    
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        contentContainer.addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(view)
        return view
    }
}

private extension MainTableAction {
    var image: UIImage? {
        switch self {
        case .debets:
            return UIImage(named: "Main.Debets")
        case .passport:
            return UIImage(named: "Main.Passport")
        }
    }
    
    var title: String {
        switch self {
        case .debets:
            return "search_debts".localized
        case .passport:
            return "check_passport_mvd".localized
        }
    }
}

private extension TextAttributes {
    static let title = TextAttributes()
        .font(UIFont.systemFont(ofSize: 13.scale))
        .lineHeight(20.scale)
        .textColor(.black)
}
