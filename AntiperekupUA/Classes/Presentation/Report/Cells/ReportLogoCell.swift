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

private extension ReportLogoCell {
    func initialize() {
        backgroundColor = .white
        contentView.backgroundColor = .white
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension ReportLogoCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            logo.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7.scale),
            logo.heightAnchor.constraint(equalToConstant: 46),
            logo.widthAnchor.constraint(equalTo: logo.heightAnchor),
            logo.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            logo.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension ReportLogoCell {
    func makeLogo() -> UIImageView {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        contentView.addSubview(view)
        return view
    }
}
