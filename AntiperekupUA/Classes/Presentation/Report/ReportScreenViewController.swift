//
//  ReportScreenViewController.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 05.08.2021.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class ReportScreenViewController: UIViewController {
    
    typealias Section = SectionModel<String, ReportTableItem>
    lazy var mainView = ReportScreenView()
    
    private lazy var disposeBag = DisposeBag()
    private typealias ConfigureCell = RxTableViewSectionedReloadDataSource<Section>.ConfigureCell
    private lazy var dataSource = RxTableViewSectionedReloadDataSource<Section>(
        configureCell: configureCell
    )
    
    private let viewModel: ReportScreenViewModel
    
    init(searchValue: ReportSearchValue) {
        viewModel = ReportScreenViewModel(searchValue: searchValue)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let input = ReportScreenViewModel.Input()
        
        let output = viewModel.configure(input: input)
        
        output.elements
            .map { $0.map { .init(model: $0.0, items: $0.1) } }
            .drive(mainView.tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    private lazy var configureCell: ConfigureCell = { _, tableView, indexPath, item in
        switch item {
        case let .header(value):
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ReportHeaderCell.self), for: indexPath) as! ReportHeaderCell
            cell.setup(for: value)
            return cell
        case let .valueWithAction(value):
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ReportValueCellWithButton.self), for: indexPath) as! ReportValueCellWithButton
            cell.setup(for: value)
            return cell
        case let .value(value):
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ReportValueCell.self), for: indexPath) as! ReportValueCell
            cell.setup(for: value)
            return cell
        case .separator:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ReportSeparatorCell.self), for: indexPath) as! ReportSeparatorCell
            return cell
        case let .text(value):
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ReportTextCell.self), for: indexPath) as! ReportTextCell
            cell.setup(for: value)
            return cell
        case let .iconWithText(value):
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ReportIconWithTextCell.self), for: indexPath) as! ReportIconWithTextCell
            cell.setup(for: value)
            return cell
        case let .error(value):
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ReportErrorCell.self), for: indexPath) as! ReportErrorCell
            cell.setup(for: value)
            return cell
        }
    }
}

// MARK: Make
extension ReportScreenViewController {
    static func make(searchValue: ReportSearchValue) -> ReportScreenViewController {
        ReportScreenViewController(searchValue: searchValue)
    }
}
