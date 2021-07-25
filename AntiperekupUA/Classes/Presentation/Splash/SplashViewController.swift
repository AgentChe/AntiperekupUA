//
//  SplashViewController.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 24.07.2021.
//

import UIKit
import RxSwift
import RxCocoa

final class SplashViewController: UIViewController {
    lazy var mainView = SplashView()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var viewModel = SplashViewModel()
    
    override func loadView() {
        view = mainView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.configure()
        
        output.showErrorAlert
            .emit(to: errorAlert)
            .disposed(by: disposeBag)
        
        let startFlow = output.showWarningAlert
            .asObservable()
            .flatMapFirst { [weak self] in
                self?.showWarning(title: $0.0, message: $0.1) ?? .empty()
            }
        
        Observable
            .merge(startFlow, output.start.asObservable())
            .withLatestFrom(output.nextFlow)
            .bind(onNext: { flow in
                switch flow {
                case .main:
                    UIApplication.shared.keyWindow?.rootViewController = MainViewController.make()
                case .onboarding:
                    UIApplication.shared.keyWindow?.rootViewController = OnboardingViewController.make()
                }
            })
            .disposed(by: disposeBag)
    }
}

private extension SplashViewController {
    var errorAlert: Binder<(String, String)> {
        return Binder(self) { base, tuple in
            let alert = UIAlertController(title: tuple.0, message: tuple.1, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { [weak base] _ in
                base?.dismiss(animated: true)
            }))
            base.present(alert, animated: true)
        }
    }
    
    func showWarning(title: String, message: String) -> Observable<Void> {
        let nextSignal = PublishRelay<Void>()
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { [weak self] _ in
            self?.dismiss(animated: true)
            nextSignal.accept(())
        }))
        self.present(alert, animated: true)
        
        return nextSignal.asObservable()
    }
}

// MARK: Make
extension SplashViewController {
    static func make() -> SplashViewController {
        SplashViewController()
    }
}
