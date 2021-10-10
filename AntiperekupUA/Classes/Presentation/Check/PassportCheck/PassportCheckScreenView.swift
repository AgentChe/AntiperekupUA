//
//  PassportCheckScreenView.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 17.09.2021.
//
import UIKit

final class PassportCheckScreenView: UIView {
    
    lazy var tableView = makeTabelView()
    lazy var loadingView = makeLoadingView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension PassportCheckScreenView {
    func initialize() {
        backgroundColor = UIColor(integralRed: 242, green: 242, blue: 242)
        tableView.register(MainErrorCell.self, forCellReuseIdentifier: String(describing: MainErrorCell.self))
        tableView.register(CheckResultCell.self, forCellReuseIdentifier: String(describing: CheckResultCell.self))
        tableView.register(PassportCheckRecordCell.self, forCellReuseIdentifier: String(describing: PassportCheckRecordCell.self))
        tableView.register(CheckDescriptionCell.self, forCellReuseIdentifier: String(describing: CheckDescriptionCell.self))
    }
}

// MARK: Make constraints
private extension PassportCheckScreenView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8.scale),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8.scale)
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
private extension PassportCheckScreenView {
    func makeTabelView() -> UITableView {
        let view = UITableView(frame: .zero, style: .grouped)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsVerticalScrollIndicator = false
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
}
