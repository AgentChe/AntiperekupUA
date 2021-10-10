//
//  DebtsCheckScreenViewController.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 24.09.2021.
//

import UIKit
import RxSwift
import RxDataSources

final class DebtsCheckScreenViewController: UIViewController {
    lazy var mainView = DebtsCheckScreenView()
    
    private lazy var fieldsHeader = DebtsCheckHeaderView()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var viewModel = DebtsCheckScreenViewModel()
    typealias Section = AnimatableSectionModel<DebtsCheckHeader, DebtsCheckTableItem>
    private typealias ConfigureCell = RxTableViewSectionedAnimatedDataSource<Section>.ConfigureCell
    
    private lazy var dataSource = RxTableViewSectionedAnimatedDataSource<Section>(
        animationConfiguration: AnimationConfiguration(insertAnimation: .none, reloadAnimation: .none, deleteAnimation: .fade),
        configureCell: configureCell
    )
    
    override func loadView() {
        view = mainView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let input = DebtsCheckScreenViewModel.Input(
            fieldData: fieldsHeader.fieldData,
            captcha: mainView.webView.captcha
        )
        
        let output = viewModel.configure(input: input)
        
        output.fieldsState
            .drive(fieldsHeader.fieldsState)
            .disposed(by: disposeBag)
        
        mainView.tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        output.showError
            .emit(to: showError)
            .disposed(by: disposeBag)
        
        output.dataSource
            .map { $0.map { .init(model: $0.0, items: $0.1) } }
            .drive(mainView.tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output.loadCaptcha
            .emit(to: mainView.webView.loadCaptcha)
            .disposed(by: disposeBag)
        
        output.isLoading
            .map(!)
            .drive(mainView.loadingView.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.showHint
            .map(!)
            .drive(mainView.hintContainer.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    private lazy var configureCell: ConfigureCell = { _, tableView, indexPath, item in
        switch item {
        case let .error(error):
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MainErrorCell.self), for: indexPath) as! MainErrorCell
            cell.setup(error: error)
            return cell
        case let .text(text):
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CheckDescriptionCell.self), for: indexPath) as! CheckDescriptionCell
            cell.setup(for: text)
            return cell
        case let .record(record):
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DebtsCheckRecordCell.self), for: indexPath) as! DebtsCheckRecordCell
            cell.setup(for: record)
            return cell
        case let .result(message,  isError):
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CheckResultCell.self), for: indexPath) as! CheckResultCell
            cell.setup(for: message, isError: isError)
            return cell
        }
    }
}

extension DebtsCheckScreenViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch dataSource[section].model {
        case .error:
            return nil
        case .action:
            return fieldsHeader
        }
    }
}

// MARK: Make
extension DebtsCheckScreenViewController {
    static func make() -> DebtsCheckScreenViewController {
        let controller = DebtsCheckScreenViewController()
        controller.title = "merchant_debt_verification".localized
        controller.configureBackButton()
        return controller
    }
}
