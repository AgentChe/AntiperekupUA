//
//  NewCommentThemeView.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 13.09.2021.
//
import UIKit

final class NewCommentThemeView: UIView {
    
    lazy var tableView = makeTableView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(integralRed: 242, green: 242, blue: 242)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Make constraints
private extension NewCommentThemeView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension NewCommentThemeView {
    func makeTableView() -> UITableView {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsVerticalScrollIndicator = false
        view.contentInset.top = 16.scale
        view.backgroundColor = UIColor(integralRed: 242, green: 242, blue: 242)
        addSubview(view)
        return view
    }
}
