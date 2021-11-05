//
//  ReportScreenView.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 05.08.2021.
//
import UIKit

final class ReportScreenView: UIView {
    lazy var tableView = makeTableView()
    lazy var paygateView = makeBottomButton()
    lazy var shareReport = makeReportButton()
    lazy var loadingView = makeLoadingView()
    private lazy var stackView = makeStackView()
    
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
        backgroundColor = UIColor(integralRed: 242, green: 242, blue: 242)
        tableView.register(ReportValueCellWithButton.self, forCellReuseIdentifier: String(describing: ReportValueCellWithButton.self))
        tableView.register(ReportValueCell.self, forCellReuseIdentifier: String(describing: ReportValueCell.self))
        tableView.register(ReportSeparatorCell.self, forCellReuseIdentifier: String(describing: ReportSeparatorCell.self))
        tableView.register(ReportTextCell.self, forCellReuseIdentifier: String(describing: ReportTextCell.self))
        tableView.register(ReportHeaderCell.self, forCellReuseIdentifier: String(describing: ReportHeaderCell.self))
        tableView.register(ReportIconWithTextCell.self, forCellReuseIdentifier: String(describing: ReportIconWithTextCell.self))
        tableView.register(ReportErrorCell.self, forCellReuseIdentifier: String(describing: ReportErrorCell.self))
        tableView.register(ReportLoadingCell.self, forCellReuseIdentifier: String(describing: ReportLoadingCell.self))
        tableView.register(ReportLogoCell.self, forCellReuseIdentifier: String(describing: ReportLogoCell.self))
        tableView.register(ReportPhotoCell.self, forCellReuseIdentifier: String(describing: ReportPhotoCell.self))
        tableView.register(ReportCommentActionCell.self, forCellReuseIdentifier: String(describing: ReportCommentActionCell.self))
        tableView.register(ReportLockedCell.self, forCellReuseIdentifier: String(describing: ReportLockedCell.self))
        tableView.register(ReportDescriptionCell.self, forCellReuseIdentifier: String(describing: ReportDescriptionCell.self))
        tableView.register(ReportImagesCarouselCell.self, forCellReuseIdentifier: String(describing: ReportImagesCarouselCell.self))
        tableView.register(ReportTitleCell.self, forCellReuseIdentifier: String(describing: ReportTitleCell.self))
        tableView.register(ReportRetryCell.self, forCellReuseIdentifier: String(describing: ReportRetryCell.self))
        tableView.register(ReportURLCell.self, forCellReuseIdentifier: String(describing: ReportURLCell.self))
        tableView.register(ReportCommentComplainCell .self, forCellReuseIdentifier: String(describing: ReportCommentComplainCell .self))
        tableView.register(ReportCheckCaptchaCell.self, forCellReuseIdentifier: String(describing: ReportCheckCaptchaCell.self))
        [shareReport, paygateView].forEach(stackView.addArrangedSubview)
    }
}

// MARK: Make constraints
private extension ReportScreenView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
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
private extension ReportScreenView {
    func makeTableView() -> UITableView {
        let view = UITableView()
        view.showsVerticalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.separatorStyle = .none
        view.contentInset.bottom = 104.scale
        view.contentInset.top = 8.scale
        addSubview(view)
        return view
    }
    
    func makeBottomButton() -> BottomButtonView {
        let view = BottomButtonView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setup(title: "activate_access_for_month".localized.uppercased(), isHiddenBottomLine: true)
        view.heightAnchor.constraint(equalToConstant: 48.scale).isActive = true
        addSubview(view)
        return view
    }
    
    func makeReportButton() -> BottomButtonView {
        let view = BottomButtonView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setup(title: "share_report".localized.uppercased(), isHiddenBottomLine: false)
        view.heightAnchor.constraint(equalToConstant: 48.scale).isActive = true
        addSubview(view)
        return view
    }
    
    func makeStackView() -> UIStackView {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 8.scale
        addSubview(view)
        return view
    }
    
    func makeLoadingView() -> ScreenLoadingView {
        let view = ScreenLoadingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
