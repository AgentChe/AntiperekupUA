//
//  ReportLogoCell.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 14.08.2021.
//
import UIKit
import Kingfisher

final class ReportLogoCell: UITableViewCell {
    
    private lazy var logo = makeLogo()
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

extension ReportLogoCell {
    func setup(for url: URL) {
        logo.kf.setImage(with: url)
    }
}

extension ReportLogoCell: CornerCellContainer {}

private extension ReportLogoCell {
    func initialize() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension ReportLogoCell {
    func makeConstraints() {
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            logo.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 7.scale),
            logo.heightAnchor.constraint(equalToConstant: 76),
            logo.widthAnchor.constraint(equalTo: logo.heightAnchor),
            logo.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            logo.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension ReportLogoCell {
    func makeLogo() -> UIImageView {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
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
