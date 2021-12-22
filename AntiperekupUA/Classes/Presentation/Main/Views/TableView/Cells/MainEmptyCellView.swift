//
//  MainEmptyCellView.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 21.12.2021.
//
import UIKit

final class MainEmptyCellView: UITableViewCell {
    
    private lazy var title = makeLabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension MainEmptyCellView {
    func initialize() {
        contentView.backgroundColor = UIColor(integralRed: 0, green: 91, blue: 187, alpha: 0.03)
        backgroundColor = UIColor(integralRed: 0, green: 91, blue: 187, alpha: 0.03)
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension MainEmptyCellView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30.scale),
            title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10.scale),
            title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension MainEmptyCellView {
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.attributedText = "no_history".localized.attributed(with: .title)
        contentView.addSubview(view)
        return view
    }
}

private extension TextAttributes {
    static let title = TextAttributes()
        .font(Fonts.SFProText.font(weight: .W500, size: 15.scale))
        .lineHeight(24.scale)
        .textColor(UIColor(integralRed: 2, green: 2, blue: 2))
        .textAlignment(.center)
}
