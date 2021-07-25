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
        
    }
}

// MARK: Make
extension MainViewController {
    static func make() -> UINavigationController {
        let controller = MainViewController()
        let navigationController = UINavigationController(rootViewController: controller)
        return navigationController
    }
}
