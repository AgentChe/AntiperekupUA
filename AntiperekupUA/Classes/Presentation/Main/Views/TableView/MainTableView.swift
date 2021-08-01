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
    
    private lazy var dataSource = RxTableViewSectionedAnimatedDataSource<Section>(
        animationConfiguration: AnimationConfiguration(insertAnimation: .top, reloadAnimation: .none, deleteAnimation: .fade),
        configureCell: configureCell
    )
    
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
        }
    }
}

extension MainTableView {
    var items: (Observable<[Section]>) -> Disposable {
        return tableView.rx.items(dataSource: dataSource)
    }
    
    var selectedElement: Signal<Section.Item> {
        tableView.rx.modelSelected(Section.Item.self).asSignal()
    }
}

private extension MainTableView {
    func initialize() {
        tableView.register(MainActionCell.self, forCellReuseIdentifier: String(describing: MainActionCell.self))
        tableView.register(MainErrorCell.self, forCellReuseIdentifier: String(describing: MainErrorCell.self))
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
