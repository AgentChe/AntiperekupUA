//
//  ReportLoadingCell.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 14.08.2021.
//
import UIKit

final class ReportLoadingCell: UITableViewCell {
    
    private lazy var loader = makeLoader()
    private lazy var label = makeLabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
        makeConstraints()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        loader.startAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ReportLoadingCell {
    func initialize() {
        backgroundColor = .white
        contentView.backgroundColor = .white
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension ReportLoadingCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            loader.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10.scale),
            loader.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loader.heightAnchor.constraint(equalToConstant: 20.scale),
            loader.widthAnchor.constraint(equalTo: loader.heightAnchor)
        ])
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: loader.bottomAnchor, constant: 10.scale),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ReportLoadingCell {
    func makeLoader() -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView()
        view.startAnimating()
        view.style = .medium
        view.color = UIColor(integralRed: 112, green: 160, blue: 172)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let attr = TextAttributes()
            .font(UIFont.systemFont(ofSize: 11.scale, weight: .regular))
            .lineHeight(18.scale)
            .textColor(UIColor(integralRed: 142, green: 143, blue: 142))
            .textAlignment(.center)
        
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        view.attributedText = "wait".localized.attributed(with: attr)
        contentView.addSubview(view)
        return view
    }
}
