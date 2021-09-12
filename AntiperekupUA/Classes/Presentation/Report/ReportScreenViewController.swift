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
    
    private let complainIdRelay = PublishRelay<Int>()
    private let changedValueRelay = PublishRelay<ReportSearchValue>()
    private let didActivateSubscription = PublishRelay<Void>()
    
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
        
        let input = ReportScreenViewModel.Input(
            inputValue: changedValueRelay.asSignal(),
            selectedElement: mainView.tableView.rx.modelSelected(ReportTableItem.self).asSignal(),
            activateSubscription: didActivateSubscription.asSignal()
        )
        
        let output = viewModel.configure(input: input)
        
        output.elements
            .map { $0.map { .init(model: $0.0, items: $0.1) } }
            .drive(mainView.tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output.showChangeAlert
            .emit(to: showChangeAlert)
            .disposed(by: disposeBag)
        
        output.isActiveSubscription
            .drive(mainView.paygateView.rx.isHidden)
            .disposed(by: disposeBag)
        
        mainView.paygateView.tap
            .emit(to: showPaygate)
            .disposed(by: disposeBag)
    }
    
    private lazy var configureCell: ConfigureCell = { [weak self] _, tableView, indexPath, item in
        switch item {
        case let .header(title, state):
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ReportHeaderCell.self), for: indexPath) as! ReportHeaderCell
            cell.setup(for: title, state: state)
            return cell
        case let .valueWithAction(value):
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ReportValueCellWithButton.self), for: indexPath) as! ReportValueCellWithButton
            cell.setup(for: value)
            return cell
        case let .value(title, value):
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ReportValueCell.self), for: indexPath) as! ReportValueCell
            cell.setup(for: title, value: value)
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
        case .loader:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ReportLoadingCell.self), for: indexPath) as! ReportLoadingCell
            return cell
        case let .logo(value):
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ReportLogoCell.self), for: indexPath) as! ReportLogoCell
            cell.setup(for: value)
            return cell
        case let .photo(value):
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ReportPhotoCell.self), for: indexPath) as! ReportPhotoCell
            cell.setup(for: value)
            return cell
        case .commentAction:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ReportCommentActionCell.self), for: indexPath) as! ReportCommentActionCell
            return cell
        case let .complain(id):
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ReportCommentComplainCell.self), for: indexPath) as! ReportCommentComplainCell
            cell.setup(id: id) { [weak self] in
                if let complainId = $0 {
                    self?.complainIdRelay.accept(complainId)
                }
            }
            return cell
        case let .locked(value):
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ReportLockedCell.self), for: indexPath) as! ReportLockedCell
            cell.setup(for: value)
            return cell
        case let .description(value):
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ReportDescriptionCell.self), for: indexPath) as! ReportDescriptionCell
            cell.setup(for: value)
            return cell
        case let .images(value):
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ReportImagesCarouselCell.self), for: indexPath) as! ReportImagesCarouselCell
            cell.setup(for: value)
            return cell
        case let .title(value):
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ReportTitleCell.self), for: indexPath) as! ReportTitleCell
            cell.setup(for: value)
            return cell
        case .retry:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ReportRetryCell.self), for: indexPath) as! ReportRetryCell
            return cell
        }
    }
}

// MARK: Make
extension ReportScreenViewController {
    static func make(searchValue: ReportSearchValue) -> ReportScreenViewController {
        let controller = ReportScreenViewController(searchValue: searchValue)
        controller.title = "report".localized
        return controller
    }
}


extension ReportScreenViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ReportAlertAnimation(duration: 0.2, animationType: .present)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ReportAlertAnimation(duration: 0.2, animationType: .dismiss)
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = ReportAlertPresentationController(presentedViewController: presented, presenting: presenting)
        return presentationController
    }
}

private extension ReportScreenViewController {
    var showChangeAlert: Binder<ReportValueWithActionModel> {
        Binder(self) { base, model in
            let alert = ReportAlertScreenViewController.make(model: model) { [weak base] result in
                base?.changedValueRelay.accept(result)
            }
            alert.transitioningDelegate = base
            alert.modalPresentationStyle = .custom
            base.present(alert, animated: true)
        }
    }
    
    var showPaygate: Binder<Void> {
        Binder(self) { base, _ in
            let controller = PaygateScreenViewController.make { [weak base] in
                base?.didActivateSubscription.accept(())
            }
            base.present(controller, animated: true)
        }
    }
}
