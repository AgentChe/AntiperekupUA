//
//  PassportCheckScreenViewController.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 17.09.2021.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class PassportCheckScreenViewController: UIViewController {
    lazy var mainView = PassportCheckScreenView()
    
    private lazy var fieldsHeader = PassportCheckHeaderView()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var viewModel = PassportCheckScreenViewModel()
    
    typealias Section = AnimatableSectionModel<PassportCheckHeader, PassportCheckTableItem>
    private typealias ConfigureCell = RxTableViewSectionedAnimatedDataSource<Section>.ConfigureCell
    
    private lazy var dataSource = RxTableViewSectionedAnimatedDataSource<Section>(
        animationConfiguration: AnimationConfiguration(insertAnimation: .none, reloadAnimation: .none, deleteAnimation: .fade),
        configureCell: configureCell
    )
    
    override func loadView() {
        view = mainView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureBackButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let input = PassportCheckScreenViewModel.Input(
            fieldData: fieldsHeader.fieldData
        )
        
        let output = viewModel.configure(input: input)
        
        output.fieldsState
            .drive(fieldsHeader.fieldsState)
            .disposed(by: disposeBag)
        
        fieldsHeader.fieldData
            .emit(to: Binder(self) { base, _ in
                base.view.endEditing(true)
            })
            .disposed(by: disposeBag)
        
        output.dataSource
            .map { $0.map { .init(model: $0.0, items: $0.1) } }
            .drive(mainView.tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output.isLoading
            .map(!)
            .drive(mainView.loadingView.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.showError
            .emit(to: showError)
            .disposed(by: disposeBag)
        
        mainView.tableView.rx
            .setDelegate(self)
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
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PassportCheckRecordCell.self), for: indexPath) as! PassportCheckRecordCell
            cell.setup(for: record)
            return cell
        case let .result(message,  isError):
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CheckResultCell.self), for: indexPath) as! CheckResultCell
            cell.setup(for: message, isError: isError)
            return cell
        }
    }
}

extension PassportCheckScreenViewController: UITableViewDelegate {
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
extension PassportCheckScreenViewController {
    static func make(series: String?, number: String?) -> PassportCheckScreenViewController {
        let controller = PassportCheckScreenViewController()
        if let series = series, let number = number {
            controller.fieldsHeader.setValues(series: series, number: number)
        }
        controller.title = "wanted_passport_menu".localized
        return controller
    }
}
