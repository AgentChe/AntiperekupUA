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
            title.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 7.scale),
            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: title.centerYAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
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
}

private extension TextAttributes {
    static let title = TextAttributes()
        .font(UIFont.systemFont(ofSize: 17.scale))
        .lineHeight(24.scale)
        .textColor(UIColor(integralRed: 2, green: 2, blue: 2))
    
    static let button = TextAttributes()
        .font(UIFont.systemFont(ofSize: 13.scale))
        .lineHeight(16.scale)
        .textColor(UIColor(integralRed: 206, green: 206, blue: 208))
}
