//
//  MainErrorCell.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 01.08.2021.
//
import UIKit

final class MainErrorCell: UITableViewCell {
    private lazy var iconView = makeIcon()
    private lazy var errorLabel = makeLabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MainErrorCell {
    func setup(error: String) {
        errorLabel.attributedText = error.attributed(with: .error)
    }
}

private extension MainErrorCell {
    func initialize() {
        backgroundColor = .white
        contentView.backgroundColor = .white
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension MainErrorCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24.scale),
            iconView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconView.heightAnchor.constraint(equalToConstant: 57.scale),
            iconView.widthAnchor.constraint(equalToConstant: 66.scale)
        ])
        
        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 24.scale),
            errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 62.scale),
            errorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -62.scale),
            errorLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension MainErrorCell {
    func makeIcon() -> UIImageView {
        let view = UIImageView()
        view.image = UIImage(named: "Main.Error")
        view.contentMode = .scaleAspectFit
        view.tintColor = UIColor(integralRed: 219, green: 156, blue: 61)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}

private extension TextAttributes {
    static let error = TextAttributes()
        .font(Fonts.SFProText.font(weight: .W500, size: 15.scale))
        .lineHeight(20.scale)
        .textColor(.black)
        .textAlignment(.center)
}
