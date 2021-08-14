//
//  ReportHeaderCell.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 11.08.2021.
//
import UIKit

final class ReportHeaderCell: UITableViewCell {
    
    private lazy var titleLabel = makeTitle()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ReportHeaderCell {
    func setup(for model: ReportHeaderModel) {
        titleLabel.attributedText = model.title.attributed(with: .title)
        contentView.backgroundColor = model.state.color
    }
}

// MARK: Make constraints
private extension ReportHeaderCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.scale),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.scale),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8.scale),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ReportHeaderCell {
    func makeTitle() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}

private extension TextAttributes {
    static let title = TextAttributes()
        .font(UIFont.systemFont(ofSize: 15.scale))
        .textColor(.black)
        .textAlignment(.center)
}

private extension ReportHeaderModel.State {
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
