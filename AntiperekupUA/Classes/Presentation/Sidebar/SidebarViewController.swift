//
//  SidebarViewController.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 10.10.2021.
//

import UIKit
import RxSwift
import MessageUI

class SidebarViewController: UIViewController {
    lazy var mainView = SidebarView()
    private let disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.closeButton.rx.tap
            .bind(to: Binder(self) { base, _ in
                base.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        mainView.didTapPolice
            .emit(to: Binder(self) { base, _ in
                guard let url = URL(string: GlobalDefinitions.termsOfServiceUrl) else { return }
                let controller = OnboardingWebViewController.make(url: url)
                base.present(controller, animated: true)
            })
            .disposed(by: disposeBag)
        
        mainView.didTapHelp
            .emit(to: Binder(self) { base, _ in
                guard MFMailComposeViewController.canSendMail() else { return }
                let messageFormat = "ID: %@ \n OS: %@ \n Version: %@ \n Device: %@ \n"
                let message = String(format: messageFormat, GlobalDefinitions.ssad, UIDevice.current.systemVersion, GlobalDefinitions.appVersion, UIDevice.current.model)
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients(["antiperekup.app@gmail.com"])
                mail.setSubject("app_name_question".localized)
                mail.setMessageBody(message, isHTML: false)
                base.present(mail, animated: true)
            })
            .disposed(by: disposeBag)
        
        mainView.didTapTechnicalCode
            .emit(to: Binder(self) { base, code in
                UIPasteboard.general.string = code
                let alert = UIAlertController(title: "", message: "copied".localized, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .cancel) { [weak alert] _ in
                    alert?.dismiss(animated: true)
                }
                alert.addAction(okAction)
                
                base.present(alert, animated: true)
            })
            .disposed(by: disposeBag)
    }
}

extension SidebarViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

// MARK: Make
extension SidebarViewController {
    static func make() -> SidebarViewController {
        return SidebarViewController()
    }
}
