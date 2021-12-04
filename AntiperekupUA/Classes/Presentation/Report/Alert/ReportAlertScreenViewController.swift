//
//  ReportAlertScreenViewController.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 24.08.2021.
//

import UIKit
import RxSwift

final class ReportAlertScreenViewController: UIViewController {
    lazy var mainView = ReportAlertScreenView()
    
    private lazy var disposeBag = DisposeBag()
    
    private let viewModel: ReportAlertScreenViewModel!
    
    private var didTapConfirm: ((ReportSearchValue) -> Void)?
    
    init(model: ReportValueWithActionModel) {
        viewModel = ReportAlertScreenViewModel(model: model)
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
        mainView.textField.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let input = ReportAlertScreenViewModel.Input(
            value: mainView.textField.rx.text.asObservable(),
            didTapConfirm: mainView.confirmButton.rx.tap.asSignal()
        )
        
        let output = viewModel.configure(input: input)
        
        mainView.setup(
            title: output.title,
            defaultValue: output.defaultValue,
            fieldType: output.fieldType
        )
        
        mainView.closeButton.rx.tap
            .bind(to: Binder(self) { base, _ in
                base.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        output.confirmed
            .emit(to: Binder(self) {
                $0.didTapConfirm?($1)
                $0.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        output.showError
            .emit(to: Binder(self) {
                $0.mainView.showError(message: $1)
                // Нужно чтобы дернуть метод preferredContentSizeDidChange у UIPresentController
                $0.preferredContentSize = $0.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Make
extension ReportAlertScreenViewController {
    static func make(model: ReportValueWithActionModel, didTapConfirm: @escaping (ReportSearchValue) -> Void) -> ReportAlertScreenViewController {
        let controller = ReportAlertScreenViewController(model: model)
        controller.didTapConfirm = didTapConfirm
        return controller
    }
}
