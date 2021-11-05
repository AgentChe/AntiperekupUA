//
//  NewCommentScreenViewController.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 12.09.2021.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class NewCommentScreenViewController: UIViewController {
    lazy var mainView = NewCommentScreenView()
    typealias Section = SectionModel<String, NewCommentCellType>
    
    private lazy var disposeBag = DisposeBag()
    
    private let viewModel: NewCommentScreenViewModel
    
    private typealias ConfigureCell = RxTableViewSectionedReloadDataSource<Section>.ConfigureCell
    
    private lazy var dataSource = RxTableViewSectionedReloadDataSource<Section>(
        configureCell: configureCell
    )
    
    private let selectedTheme = PublishRelay<NewCommentTheme>()
    private let titleRelay = BehaviorRelay<String?>(value: nil)
    private let commentRelay = BehaviorRelay<String?>(value: nil)
    private var didCommentAdded: (() -> Void)?
    
    private lazy var rightButton: UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.title = "send".localized
        return item
    }()
    
    init(vin: String, regNumber: String) {
        viewModel = NewCommentScreenViewModel(vin: vin, regNumber: regNumber)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureBackButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = rightButton
        
        let input = NewCommentScreenViewModel.Input(
            selectedTheme: selectedTheme.asSignal(),
            title: titleRelay.asObservable(),
            comment: commentRelay.asObservable(),
            didTapSend: rightButton.rx.tap.asSignal()
        )
        
        let output = viewModel.configure(input: input)
        
        output.dataSource
            .map { [Section(model: "", items: $0)] }
            .drive(mainView.tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output.isSendEnabled
            .drive(rightButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.isLoading
            .map(!)
            .drive(mainView.loadingView.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.commentAdded
            .emit(to: Binder(self) { base, _ in
                base.didCommentAdded?()
                base.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        output.showError
            .emit(to: showError)
            .disposed(by: disposeBag)
        
        mainView.tableView.rx.modelSelected(NewCommentCellType.self)
            .asObservable()
            .compactMap { type -> Void? in
                guard case .selector = type else { return nil }
                return ()
            }
            .bind(to: showTheme)
            .disposed(by: disposeBag)
    }
    
    private lazy var configureCell: ConfigureCell = { [weak self] _, tableView, indexPath, item in
        switch item {
        case let .selector(current):
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: NewCommentThemeCell.self), for: indexPath) as! NewCommentThemeCell
            cell.setup(for: current)
            return cell
        case .title:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: NewCommentTitleCell.self), for: indexPath) as! NewCommentTitleCell
            cell.setup { [weak self] in
                self?.titleRelay.accept($0)
            }
            return cell
        case .comment:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: NewCommentCommentCell.self), for: indexPath) as! NewCommentCommentCell
            cell.setup { [weak self] in
                self?.commentRelay.accept($0)
            }
            return cell
        case let .header(title):
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: NewCommentHeaderCell.self), for: indexPath) as! NewCommentHeaderCell
            cell.setup(for: title)
            return cell
        }
    }
}

// MARK: Make
extension NewCommentScreenViewController {
    static func make(vin: String, regNumber: String, didCommentAdded: @escaping () -> Void) -> NewCommentScreenViewController {
        let controller = NewCommentScreenViewController(vin: vin, regNumber: regNumber)
        controller.title = "new_comment".localized
        controller.didCommentAdded = didCommentAdded
        return controller
    }
}

private extension NewCommentScreenViewController {
    var showTheme: Binder<Void> {
        return Binder(self) { base, _ in
            let controller = NewCommentThemeViewController.make { [weak base] in
                base?.selectedTheme.accept($0)
                base?.navigationController?.popViewController(animated: true)
            }
            
            base.navigationController?.pushViewController(controller, animated: true)
        }
    }
}
