//
//  OnboardingViewController.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 20.07.2021.
//

import UIKit
import RxSwift

final class OnboardingViewController: UIViewController {
    lazy var mainView = OnboardingView()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var viewModel = OnboardingViewModel()
    
    override func loadView() {
        view = mainView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.languageView.openURL = { [weak self] url in
            let webView = OnboardingWebViewController.make(url: url)
            self?.present(webView, animated: true)
        }
        let input = OnboardingViewModel.Input(
            selectedLanguage: mainView.languageView.selectedLanguage,
            didTapStart: mainView.languageView.didTapStart
        )
        let output = viewModel.configure(input: input)
        
        output.showMain
            .emit(onNext: {
                UIApplication.shared.keyWindow?.rootViewController = MainViewController.make()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Make
extension OnboardingViewController {
    static func make() -> OnboardingViewController {
        OnboardingViewController()
    }
}
