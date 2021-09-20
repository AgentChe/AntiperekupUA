//
//  NewCommentThemeViewController.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 13.09.2021.
//

import UIKit
import RxSwift

final class NewCommentThemeViewController: UIViewController {
    lazy var mainView = NewCommentThemeView()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var viewModel = NewCommentThemeViewModel()
    private let elements = NewCommentTheme.allCases
    private var selectedTheme: ((NewCommentTheme) -> Void)?
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.tableView.delegate = self
        mainView.tableView.dataSource = self
    }
}

extension NewCommentThemeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTheme?(elements[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}

extension NewCommentThemeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .white
        cell.textLabel?.attributedText = elements[indexPath.row].name.attributed(with: .text)
        cell.selectionStyle = .none
        return cell
    }
}

// MARK: Make
extension NewCommentThemeViewController {
    static func make(selectedTheme: @escaping (NewCommentTheme) -> Void) -> NewCommentThemeViewController {
        let controller = NewCommentThemeViewController()
        controller.selectedTheme = selectedTheme
        controller.configureBackButton()
        return controller
    }
}

private extension TextAttributes {
    static let text = TextAttributes()
        .font(Fonts.SFProText.font(weight: .W400, size: 17.scale))
        .lineHeight(22.scale)
        .textColor(.black)
}
