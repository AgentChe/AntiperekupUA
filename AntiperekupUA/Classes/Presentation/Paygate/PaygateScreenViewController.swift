//
//  PaygateScreenViewController.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 26.08.2021.
//

import UIKit
import RxSwift
import RxCocoa

final class PaygateScreenViewController: UIViewController {
    lazy var mainView = PaygateScreenView()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var viewModel = PaygateScreenViewModel()
    
    private var didBuyed: (() -> Void)?
    
    override func loadView() {
        view = mainView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
        let input = PaygateScreenViewModel.Input(
            productId: Signal.merge(mainView.monthProduct.productId, mainView.sixMonthProduct.productId),
            didTapRestore: mainView.restoreButton.rx.tap.asSignal()
        )
        
        let output = viewModel.configure(input: input)
        
        output.products
            .drive(Binder(mainView) { base, tuple in
                base.monthProduct.setup(product: tuple.one)
                base.sixMonthProduct.setup(product: tuple.six)
            })
            .disposed(by: disposeBag)
        
        output.errorMessage
            .emit(to: showError)
            .disposed(by: disposeBag)
        
        output.productIsLoading
            .drive(Binder(mainView) {
                $0.productLoader.isHidden = !$1
                $0.monthProduct.isHidden = $1
                $0.sixMonthProduct.isHidden = $1
            })
            .disposed(by: disposeBag)
        
        output.productIsBuying
            .map(!)
            .drive(mainView.loadingView.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.productBuyedSignal
            .emit(to: Binder(self) { base, _ in
                base.didBuyed?()
                base.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        mainView.openURL = { [weak self] url in
            self?.present(OnboardingWebViewController.make(url: url), animated: true)
        }
    }
    
    private func configureUI() {
        title = "premium_access_title".localized
        let rightItem = UIBarButtonItem(
            image: UIImage(named: "Paygate.Cancel"), style: .done, target: self, action: #selector(didTapClose))
        rightItem.tintColor = UIColor(integralRed: 2, green: 2, blue: 2, alpha: 0.4)
        navigationItem.rightBarButtonItem = rightItem
        navigationController?.navigationBar.shadowImage = nil
    }
}

private extension PaygateScreenViewController {
    @objc func didTapClose() {
        dismiss(animated: true)
    }
}

// MARK: Make
extension PaygateScreenViewController {
    static func make(didBuyed: @escaping () -> Void) -> UINavigationController {
        let controller = PaygateScreenViewController()
        controller.didBuyed = didBuyed
        let nc = UINavigationController(rootViewController: controller)
        nc.modalPresentationStyle = .fullScreen
        return nc
    }
}
