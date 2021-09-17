//
//  NewCommentScreenView.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 12.09.2021.
//
import UIKit

final class NewCommentScreenView: UIView {
    
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

private extension NewCommentScreenView {
    func initialize() {
        backgroundColor = UIColor(integralRed: 242, green: 242, blue: 242)
        tableView.register(NewCommentThemeCell.self, forCellReuseIdentifier: String(describing: NewCommentThemeCell.self))
        tableView.register(NewCommentTitleCell.self, forCellReuseIdentifier: String(describing: NewCommentTitleCell.self))
        tableView.register(NewCommentCommentCell.self, forCellReuseIdentifier: String(describing: NewCommentCommentCell.self))
        tableView.register(NewCommentHeaderCell.self, forCellReuseIdentifier: String(describing: NewCommentHeaderCell.self))
    }
}

// MARK: Make constraints
private extension NewCommentScreenView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor)
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
private extension NewCommentScreenView {
    func makeTabelView() -> UITableView {
        let view = UITableView(frame: .zero, style: .plain)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsVerticalScrollIndicator = false
        view.backgroundColor = UIColor(integralRed: 242, green: 242, blue: 242)
        view.separatorStyle = .none
        view.contentInset.top = 16
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
