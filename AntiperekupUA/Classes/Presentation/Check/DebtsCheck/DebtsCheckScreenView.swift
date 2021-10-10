//
//  DebtsCheckScreenView.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 24.09.2021.
//
import UIKit

final class DebtsCheckScreenView: UIView {
    
    lazy var tableView = makeTabelView()
    lazy var loadingView = makeLoadingView()
    lazy var webView = makeWebView()
    lazy var hintContainer = makeHintContainer()
    private lazy var hintLabel = makeHintLabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension DebtsCheckScreenView {
    func initialize() {
        backgroundColor = UIColor(integralRed: 242, green: 242, blue: 242)
        tableView.register(MainErrorCell.self, forCellReuseIdentifier: String(describing: MainErrorCell.self))
        tableView.register(CheckResultCell.self, forCellReuseIdentifier: String(describing: CheckResultCell.self))
        tableView.register(DebtsCheckRecordCell.self, forCellReuseIdentifier: String(describing: DebtsCheckRecordCell.self))
        tableView.register(CheckDescriptionCell.self, forCellReuseIdentifier: String(describing: CheckDescriptionCell.self))
    }
}

// MARK: Make constraints
private extension DebtsCheckScreenView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8.scale),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8.scale)
        ])
        
        NSLayoutConstraint.activate([
            hintContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            hintContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            hintContainer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            hintLabel.topAnchor.constraint(equalTo: hintContainer.topAnchor),
            hintLabel.bottomAnchor.constraint(equalTo: hintContainer.bottomAnchor, constant: -32.scale),
            hintLabel.leadingAnchor.constraint(equalTo: hintContainer.leadingAnchor, constant: 8.scale),
            hintLabel.trailingAnchor.constraint(equalTo: hintContainer.trailingAnchor, constant: -8.scale)
        ])
        
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension DebtsCheckScreenView {
    func makeTabelView() -> UITableView {
        let view = UITableView(frame: .zero, style: .grouped)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsVerticalScrollIndicator = false
        view.contentInset.bottom = 80.scale
        view.backgroundColor = UIColor(integralRed: 242, green: 242, blue: 242)
        view.separatorStyle = .none
        view.keyboardDismissMode = .interactive
        addSubview(view)
        return view
    }
    
    func makeLoadingView() -> ScreenLoadingView {
        let view = ScreenLoadingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        addSubview(view)
        return view
    }
    
    func makeWebView() -> DebtsCheckWebView {
        let view = DebtsCheckWebView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        addSubview(view)
        return view
    }
    
    func makeHintContainer() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(integralRed: 242, green: 242, blue: 242)
        addSubview(view)
        return view
    }
    
    func makeHintLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        view.attributedText = "warning_only_ukr".localized.attributed(with: .hint)
        hintContainer.addSubview(view)
        return view
    }
}

private extension TextAttributes {
    static let hint = TextAttributes()
        .font(Fonts.SFProDisplay.font(weight: .W400, size: 14.scale))
        .lineHeight(16.scale)
        .textColor(UIColor(integralRed: 40, green: 42, blue: 48))
        .textAlignment(.center)
}
