//
//  MainHistoryHeaderView.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 01.08.2021.
//
import UIKit
import RxCocoa
import RxSwift

final class MainHistoryHeaderView: UIView {
    private lazy var title = makeTitle()
    private lazy var button = makeButton()
    private lazy var separator = makeSeparator()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MainHistoryHeaderView {
    var didTapClear: Signal<Void> {
        button.rx.tap.asSignal()
    }
}

// MARK: Make constraints
private extension MainHistoryHeaderView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: topAnchor, constant: 24.scale),
            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: title.centerYAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
        ])
        
        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 7.scale),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension MainHistoryHeaderView {
    func makeTitle() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.attributedText = "audit_history".localized.attributed(with: .title)
        addSubview(view)
        return view
    }
    
    func makeButton() -> UIButton {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setAttributedTitle("clear".localized.attributed(with: .button), for: .normal)
        addSubview(view)
        return view
    }
    
    func makeSeparator() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(integralRed: 206, green: 206, blue: 208, alpha: 0.6)
        addSubview(view)
        return view
    }
}

private extension TextAttributes {
    static let title = TextAttributes()
        .font(Fonts.SFProText.font(weight: .W500, size: 17.scale))
        .lineHeight(24.scale)
        .textColor(UIColor(integralRed: 2, green: 2, blue: 2))
    
    static let button = TextAttributes()
        .font(Fonts.SFProText.font(weight: .W400, size: 13.scale))
        .lineHeight(16.scale)
        .textColor(UIColor(integralRed: 206, green: 206, blue: 208))
}
