//
//  UIControllerExtension.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 17.09.2021.
//

import UIKit
import RxSwift
import RxCocoa

extension UIViewController {
    var showError: Binder<String> {
        Binder(self) { base, message in
            let alert = UIAlertController(title: "error".localized, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel) { [weak base] _ in
                base?.dismiss(animated: true)
            }
            
            alert.addAction(action)
            base.present(alert, animated: true)
        }
    }
    
    func configureBackButton() {
        let icon = navigationController?.viewControllers.count ?? 0 > 1
        ? UIImage(named: "ChevronLeft")
        : UIImage(named: "Paygate.Cancel")
        let action = UIBarButtonItem(image: icon, style: .plain, target: self, action: #selector(backAction))
        navigationItem.leftBarButtonItem = action
    }
    
    @objc func backAction(_ item: UIBarButtonItem) {
        if navigationController?.viewControllers.count ?? 0 > 1 {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}
