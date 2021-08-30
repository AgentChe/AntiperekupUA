//
//  PaygateCheckView.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 26.08.2021.
//
import UIKit

final class PaygateCheckView: UIView {
    private lazy var icon = makeIcon()
    private lazy var label = makeLabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PaygateCheckView {
    func setup(for title: String) {
        label.attributedText = title.attributed(with: .title)
    }
}

private extension PaygateCheckView {
    func initialize() {
        backgroundColor = .clear
    }
}

// MARK: Make constraints
private extension PaygateCheckView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            icon.heightAnchor.constraint(equalToConstant: 16.scale),
            icon.widthAnchor.constraint(equalTo: icon.heightAnchor),
            icon.leadingAnchor.constraint(equalTo: leadingAnchor),
            icon.centerYAnchor.constraint(equalTo: label.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 8.scale),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension PaygateCheckView {
    func makeIcon() -> UIImageView {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(named: "Paygate.Checked")
        view.contentMode = .scaleAspectFit
        addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        addSubview(view)
        return view
    }
}

private extension TextAttributes {
    static let title = TextAttributes()
        .font(Fonts.SFProDisplay.font(weight: .W400, size: 15.scale))
        .lineHeight(18.scale)
        .textColor(UIColor(integralRed: 2, green: 2, blue: 2))
}
