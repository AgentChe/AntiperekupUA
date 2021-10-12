//
//  SidebarView.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 10.10.2021.
//

import UIKit
import RxSwift
import RxCocoa

class SidebarView: UIView {
    
    lazy var closeButton = makeCloseButton()
    private lazy var policeButton = sidebarItemView(
        title: "privacy_policy".localized,
        icon: UIImage(named: "Sidebar.Police"),
        action: #selector(didTapPoliceButton)
    )
    private lazy var helpButton = sidebarItemView(
        title: "technical_support".localized,
        icon: UIImage(named: "Sidebar.Help"),
        action: #selector(didTapHelpButton)
    )
    private lazy var technicalButton = sidebarItemView(
        title: "code_support".localized,
        icon: UIImage(named: "Sidebar.Support"),
        action: #selector(didTapTechnicalButton),
        subtitle: UIDevice.idfv?.uppercased()
    )
    
    private let didTapPoliceRelay = PublishRelay<Void>()
    private let didTapHelpRelay = PublishRelay<Void>()
    private let didTapTechnicalRelay = PublishRelay<String>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SidebarView {
    var didTapPolice: Signal<Void> {
        didTapPoliceRelay.asSignal()
    }
    
    var didTapHelp: Signal<Void> {
        didTapHelpRelay.asSignal()
    }
    
    var didTapTechnicalCode: Signal<String> {
        didTapTechnicalRelay.asSignal()
    }
}

private extension SidebarView {
    func initialize() {
        backgroundColor = .white
    }
    
    @objc func didTapPoliceButton() {
        didTapPoliceRelay.accept(())
    }
    
    @objc func didTapHelpButton() {
        didTapHelpRelay.accept(())
    }
    
    @objc func didTapTechnicalButton() {
        didTapTechnicalRelay.accept(UIDevice.idfv?.uppercased() ?? "")
    }
}

// MARK: Make constraints
private extension SidebarView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            closeButton.heightAnchor.constraint(equalToConstant: 14.scale),
            closeButton.widthAnchor.constraint(equalTo: closeButton.heightAnchor),
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 44.scale),
            closeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14.scale)
        ])
        
        NSLayoutConstraint.activate([
            policeButton.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 34.scale),
            policeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8.scale),
            policeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8.scale)
        ])
        
        NSLayoutConstraint.activate([
            helpButton.topAnchor.constraint(equalTo: policeButton.bottomAnchor, constant: 21.scale),
            helpButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8.scale),
            helpButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8.scale)
        ])
        
        NSLayoutConstraint.activate([
            technicalButton.topAnchor.constraint(equalTo: helpButton.bottomAnchor, constant: 21.scale),
            technicalButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8.scale),
            technicalButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8.scale),
            technicalButton.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -10.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension SidebarView {
    func sidebarItemView(title: String, icon: UIImage?, action: Selector, subtitle: String? = nil) -> SidebarItemView {
        let view = SidebarItemView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setup(for: icon, title: title, subtitle: subtitle)
        let gesture = UITapGestureRecognizer(target: self, action: action)
        view.addGestureRecognizer(gesture)
        addSubview(view)
        return view
    }
    
    func makeCloseButton() -> UIButton {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = .black
        view.setImage(UIImage(named: "Paygate.Cancel"), for: .normal)
        view.tintColor = .black
        addSubview(view)
        return view
    }
}
