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
    private let sidebarPresentDelegate = SidebarAnimationDelegate()
    
    override func loadView() {
        view = mainView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
        let input = MainViewModel.Input(
            searchValue: mainView.tableView.searchHeader.searchText,
            didTapSearch: mainView.tableView.searchHeader.didTapSearch,
            tabIndex: mainView.segmentView.selectIndex,
            didTapClear: mainView.tableView.historyHeader.didTapClear,
            itemSelected: mainView.tableView.selectedElement,
            deleteHistoryItem: mainView.tableView.deleteHistoryItem
        )
        
        let output = viewModel.configure(input: input)
        
        output.searchModel
            .drive(mainView.tableView.searchHeader.searchModel)
            .disposed(by: disposeBag)
        
        output.isError
            .drive(mainView.tableView.searchHeader.isError)
            .disposed(by: disposeBag)
        
        mainView.tableView.searchHeader.didTapSearch
            .emit(to: Binder(self) { base, _ in
                base.view.endEditing(true)
            })
            .disposed(by: disposeBag)
        
        output.tableData
            .map { $0.map { .init(model: $0.0, items: $0.1) } }
            .drive(mainView.tableView.items)
            .disposed(by: disposeBag)
        
        output.route
            .emit(to: navigation)
            .disposed(by: disposeBag)
        
        output.savedSearchValue
            .drive(mainView.tableView.searchHeader.savedValue)
            .disposed(by: disposeBag)
    }
    
    private func configureUI() {
        let leftItem = UIBarButtonItem(
            image: UIImage(named: "Main.Sidebar"), style: .done, target: self, action: #selector(didTapMenu))
        leftItem.tintColor = .black
        navigationItem.leftBarButtonItem = leftItem
    }
    
    @objc private func didTapMenu() {
        let controller = SidebarViewController.make()
        controller.transitioningDelegate = sidebarPresentDelegate
        controller.modalPresentationStyle = .custom
        present(controller, animated: true)
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
            case let .regValidation(value):
                let controller = MTSBUScreenViewController.make(regNumber: value)
                base.navigationController?.pushViewController(controller, animated: true)
            case let .checkPassport(series, number):
                let controller = PassportCheckScreenViewController.make(series: series, number: number)
                base.navigationController?.pushViewController(controller, animated: true)
            case let .checkDebets(data):
                let controller = DebtsCheckScreenViewController.make(data: data)
                base.navigationController?.pushViewController(controller, animated: true)
            case let .report(searchValue):
                let controller = ReportScreenViewController.make(searchValue: searchValue, captcha: nil)
                base.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}
