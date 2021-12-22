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
    lazy var containerView = makeContainer()
    
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
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
    }
}

extension ReportLoadingCell: CornerCellContainer {}

// MARK: Make constraints
private extension ReportLoadingCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding)
        ])
        
        NSLayoutConstraint.activate([
            loader.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10.scale),
            loader.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            loader.heightAnchor.constraint(equalToConstant: 20.scale),
            loader.widthAnchor.constraint(equalTo: loader.heightAnchor)
        ])
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: loader.bottomAnchor, constant: 10.scale),
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16.scale),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16.scale),
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10.scale)
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
        containerView.addSubview(view)
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
