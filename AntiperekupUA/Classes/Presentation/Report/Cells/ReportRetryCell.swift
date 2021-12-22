//
//  ReportRetryCell.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 31.08.2021.
//
import UIKit

final class ReportRetryCell: UITableViewCell {
    
    private lazy var retryLabel = makeLabel()
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

extension ReportRetryCell: CornerCellContainer {}

private extension ReportRetryCell {
    func initialize() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension ReportRetryCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding)
        ])
        
        NSLayoutConstraint.activate([
            retryLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8.scale),
            retryLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20.scale),
            retryLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20.scale),
            retryLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ReportRetryCell {
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.attributedText = "check_repeat".localized.attributed(with: .title)
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
    static let title = TextAttributes()
        .font(Fonts.SFProText.font(weight: .W700, size: 12.scale))
        .textColor(UIColor(integralRed: 112, green: 160, blue: 172))
        .textAlignment(.right)
}
