//
//  MainViewController.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 25.07.2021.
//

import UIKit
import RxSwift

final class MainViewController: UIViewController {
    lazy var mainView = MainView()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var viewModel = MainViewModel()
    
    override func loadView() {
        view = mainView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let input = MainViewModel.Input(
            searchValue: mainView.tableView.searchHeader.searchText,
            tabIndex: mainView.segmentView.selectIndex,
            didTapClear: mainView.tableView.historyHeader.didTapClear,
            itemSelected: mainView.tableView.selectedElement,
            deleteHistoryItem: mainView.tableView.deleteHistoryItem
        )
        
        let output = viewModel.configure(input: input)
        
        output.searchPlaceholder
            .drive(mainView.tableView.searchHeader.placeholder)
            .disposed(by: disposeBag)
        
        output.isError
            .drive(mainView.tableView.searchHeader.isError)
            .disposed(by: disposeBag)
        
        output.tableData
            .map { $0.map { .init(model: $0.0, items: $0.1) } }
            .drive(mainView.tableView.items)
            .disposed(by: disposeBag)
        
        output.route
            .emit(to: navigation)
            .disposed(by: disposeBag)
    }
}

// MARK: Make
extension MainViewController {
    static func make() -> UINavigationController {
        let controller = MainViewController()
        let navigationController = UINavigationController(rootViewController: controller)
        controller.title = "ukraine_mvd_database".localized
        return navigationController
    }
}

private extension MainViewController {
    var navigation: Binder<MainRoute> {
        Binder(self) { base, route in
            switch route {
            case .regValidation:
                break
            case .checkPassport:
                let controller = PassportCheckScreenViewController.make()
                base.navigationController?.pushViewController(controller, animated: true)
            case .checkDebets:
                break
            case let .report(searchValue):
                let controller = ReportScreenViewController.make(searchValue: searchValue)
                base.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}
