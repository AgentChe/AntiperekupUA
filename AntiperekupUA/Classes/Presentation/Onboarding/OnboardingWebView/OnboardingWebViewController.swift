//
//  OnboardingWebViewController.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 24.07.2021.
//

import UIKit

final class OnboardingWebViewController: UIViewController {
    lazy var mainView = OnboardingWebView()
    
    override func loadView() {
        view = mainView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: Make
extension OnboardingWebViewController {
    static func make(url: URL) -> OnboardingWebViewController {
        let controller = OnboardingWebViewController()
        controller.mainView.webView.load(URLRequest(url: url))
        return controller
    }
}
