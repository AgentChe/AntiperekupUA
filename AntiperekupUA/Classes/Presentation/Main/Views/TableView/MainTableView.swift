//
//  MainTableView.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 27.07.2021.
//
import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class MainTableView: UIView {
    
    private lazy var tableView = makeTableView()
    lazy var searchHeader = makeSearchHeader()
    lazy var historyHeader = makeHistoryHeader()
    
    typealias Section = AnimatableSectionModel<MainTableHeader, MainTableItem>
    private typealias ConfigureCell = RxTableViewSectionedAnimatedDataSource<Section>.ConfigureCell
    private typealias CanEditRowAtIndexPath = (TableViewSectionedDataSource<Section>, IndexPath) -> Bool
    
    private lazy var dataSource = RxTableViewSectionedAnimatedDataSource<Section>(
        animationConfiguration: AnimationConfiguration(insertAnimation: .top, reloadAnimation: .none, deleteAnimation: .fade),
        configureCell: configureCell,
        canEditRowAtIndexPath: canEditRowAtIndexPath
    )
    
    private let deletedHistoryItemRelay = PublishRelay<MainHistoryItem>()
    
    private let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var configureCell: ConfigureCell = { _, tableView, indexPath, item in
        switch item {
        case let .action(action):
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MainActionCell.self), for: indexPath) as! MainActionCell
            cell.setup(for: action)
            return cell
        case let .error(error):
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MainErrorCell.self), for: indexPath) as! MainErrorCell
            cell.setup(error: error)
            return cell
        case let .history(element):
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MainHistoryCell.self), for: indexPath) as! MainHistoryCell
            cell.setup(from: element)
            return cell
        case .empty:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MainEmptyCellView.self), for: indexPath) as! MainEmptyCellView
            return cell
        }
    }
    
    private lazy var canEditRowAtIndexPath: CanEditRowAtIndexPath = { dataSource, indexPath -> Bool in
        guard case .history = dataSource[indexPath] else {
            return false
        }
        
        return true
    }
}

extension MainTableView {
    var items: (Observable<[Section]>) -> Disposable {
        return tableView.rx.items(dataSource: dataSource)
    }
    
    var selectedElement: Signal<Section.Item> {
        tableView.rx.modelSelected(Section.Item.self).asSignal()
    }
    
    var deleteHistoryItem: Signal<MainHistoryItem> {
        deletedHistoryItemRelay.asSignal()
    }
    
    var isScrollEnabled: Binder<Bool> {
        tableView.rx.isScrollEnabled
    }
}

private extension MainTableView {
    func initialize() {
        tableView.register(MainActionCell.self, forCellReuseIdentifier: String(describing: MainActionCell.self))
        tableView.register(MainErrorCell.self, forCellReuseIdentifier: String(describing: MainErrorCell.self))
        tableView.register(MainHistoryCell.self, forCellReuseIdentifier: String(describing: MainHistoryCell.self))
        tableView.register(MainEmptyCellView.self, forCellReuseIdentifier: String(describing: MainEmptyCellView.self))
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
}

extension MainTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch dataSource[section].model {
        case .error:
            return nil
        case .action:
            return searchHeader
        case .history:
            return historyHeader
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "remove".localized, handler: { [weak self] _,_,_ in
            guard case let .history(item) = self?.dataSource[indexPath] else { return }
            self?.deletedHistoryItemRelay.accept(item)
        })
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch dataSource[indexPath.section].items[indexPath.row] {
        case .empty:
            return abs(tableView.bounds.height - tableView.contentSize.height) + 50.scale
        default:
            return UITableView.automaticDimension
        }
    }
}

// MARK: Make constraints
private extension MainTableView {
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
private extension MainTableView {
    func makeTableView() -> UITableView {
        let view = UITableView(frame: .zero, style: .grouped)
        view.showsVerticalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.separatorStyle = .none
        addSubview(view)
        return view
    }
    
    func makeSearchHeader() -> MainSearchHeaderView {
        let view = MainSearchHeaderView()
        view.backgroundColor = .white
        return view
    }
    
    func makeHistoryHeader() -> MainHistoryHeaderView {
        let view = MainHistoryHeaderView()
        view.backgroundColor = .white
        return view
    }
}
