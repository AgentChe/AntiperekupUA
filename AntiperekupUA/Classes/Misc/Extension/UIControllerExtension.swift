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
        let icon = UIImage(named: "ChevronLeft")
        let action = UIBarButtonItem(image: icon, style: .plain, target: self, action: #selector(backAction))
        navigationItem.leftBarButtonItem = action
    }
    
    @objc func backAction(_ item: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
}
