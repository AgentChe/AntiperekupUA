//
//  ReportHeaderCell.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 11.08.2021.
//
import UIKit

final class ReportHeaderCell: UITableViewCell {
    
    private lazy var titleLabel = makeTitle()
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

extension ReportHeaderCell {
    func setup(for title: String, state: ReportHeaderState) {
        titleLabel.attributedText = title.attributed(with: .title)
        containerView.backgroundColor = state.color
    }
}

extension ReportHeaderCell: CornerCellContainer {}

private extension ReportHeaderCell {
    func initialize() {
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension ReportHeaderCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8.scale),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8.scale),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8.scale),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ReportHeaderCell {
    func makeTitle() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(view)
        return view
    }
    
    func makeContainer() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}

private extension TextAttributes {
    static let title = TextAttributes()
        .font(Fonts.SFProText.font(weight: .W600, size: 15.scale))
        .textColor(.black)
        .textAlignment(.center)
}

private extension ReportHeaderState {
    var color: UIColor {
        switch self {
        case .success:
            return UIColor(integralRed: 162, green: 212, blue: 179)
        case .error:
            return UIColor(integralRed: 240, green: 134, blue: 129)
        case .empty:
            return UIColor(integralRed: 232, green: 235, blue: 238)
        }
    }
}
