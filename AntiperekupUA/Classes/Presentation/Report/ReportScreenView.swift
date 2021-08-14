//
//  ReportScreenView.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 05.08.2021.
//
import UIKit

final class ReportScreenView: UIView {
    lazy var tableView = makeTableView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ReportScreenView {
    func initialize() {
        tableView.register(ReportValueCellWithButton.self, forCellReuseIdentifier: String(describing: ReportValueCellWithButton.self))
        tableView.register(ReportValueCell.self, forCellReuseIdentifier: String(describing: ReportValueCell.self))
        tableView.register(ReportSeparatorCell.self, forCellReuseIdentifier: String(describing: ReportSeparatorCell.self))
        tableView.register(ReportTextCell.self, forCellReuseIdentifier: String(describing: ReportTextCell.self))
        tableView.register(ReportHeaderCell.self, forCellReuseIdentifier: String(describing: ReportHeaderCell.self))
        tableView.register(ReportIconWithTextCell.self, forCellReuseIdentifier: String(describing: ReportIconWithTextCell.self))
        tableView.register(ReportErrorCell.self, forCellReuseIdentifier: String(describing: ReportErrorCell.self))
    }
}

// MARK: Make constraints
private extension ReportScreenView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension ReportScreenView {
    func makeTableView() -> UITableView {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        // Т.к. стиль сгруппированный, contentInset работает некорректно
        view.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 16, right: 16)
        view.showsVerticalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(integralRed: 242, green: 242, blue: 242)
        view.separatorStyle = .none
        addSubview(view)
        return view
    }
}
