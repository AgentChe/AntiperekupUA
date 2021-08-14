//
//  BottomButtonView.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 01.08.2021.
//
import UIKit
import RxSwift
import RxCocoa

final class BottomButtonView: UIView {
    private lazy var button = makeButton()
    private lazy var topLine = makeLineView()
    private lazy var bottomLine = makeLineView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BottomButtonView {
    func setup(title: String, isHiddenBottomLine: Bool) {
        button.setAttributedTitle(title.attributed(with: .title), for: .normal)
        bottomLine.isHidden = isHiddenBottomLine
    }
}

// MARK: Make constraints
private extension BottomButtonView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            topLine.topAnchor.constraint(equalTo: topAnchor),
            topLine.leadingAnchor.constraint(equalTo: leadingAnchor),
            topLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            topLine.heightAnchor.constraint(equalToConstant: 1.scale)
        ])
        
        NSLayoutConstraint.activate([
            bottomLine.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomLine.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomLine.heightAnchor.constraint(equalToConstant: 1.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension BottomButtonView {
    func makeButton() -> UIButton {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(integralRed: 160, green: 179, blue: 204)
        addSubview(view)
        return view
    }
    
    func makeLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(integralRed: 160, green: 179, blue: 204)
        addSubview(view)
        return view
    }
}

private extension TextAttributes {
    static let title = TextAttributes()
        .font(UIFont.systemFont(ofSize: 20.scale))
        .lineHeight(24.scale)
        .textColor(UIColor(integralRed: 40, green: 42, blue: 48))
}
