//
//  MTSBUScreenViewController.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 12.10.2021.
//

import UIKit
import RxSwift

final class MTSBUScreenViewController: UIViewController {
    lazy var mainView = MTSBUScreenView()
    
    private lazy var disposeBag = DisposeBag()
    
    private let viewModel: MTSBUScreenViewModel
    
    private var completion: (() -> Void)?
    
    init(regNumber: String) {
        viewModel = MTSBUScreenViewModel(regNumber: regNumber)
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
        
        let input = MTSBUScreenViewModel.Input(
            cookies: mainView.webView.cookies,
            captcha: mainView.webView.captcha,
            captchaIsLoaded: mainView.webView.captchaLoaded,
            didTapSkip: mainView.skipButton.tap,
            loadError: mainView.webView.loadError
        )
        
        let output = viewModel.configure(input: input)
        
        mainView.webView.captchaLoaded
            .map { _ in true }
            .drive(mainView.webView.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.searchValue
            .emit(to: Binder(self) { base, searchValue in
                if base.navigationController?.viewControllers.first === base {
                    base.completion?()
                    base.dismiss(animated: true)
                } else {
                    let controller = ReportScreenViewController.make(searchValue: searchValue)
                    let mainController = base.navigationController?.viewControllers.first
                    let controllers = [mainController, controller].compactMap { $0 }
                    base.navigationController?.setViewControllers(controllers, animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        mainView.webView.captchaLoaded
            .map(!)
            .drive(mainView.webView.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.cookies
            .emit(to: mainView.webView.newCookies)
            .disposed(by: disposeBag)
        
        output.retryLoad
            .emit(to: mainView.webView.retryLoad)
            .disposed(by: disposeBag)
    }
}

// MARK: Make
extension MTSBUScreenViewController {
    static func make(regNumber: String, completion: (() -> Void)? = nil) -> MTSBUScreenViewController {
        let controller = MTSBUScreenViewController(regNumber: regNumber)
        controller.completion = completion
        controller.title = "app_name".localized
        return controller
    }
}
