//
//  DebtsCheckWebView.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 27.09.2021.
//
import UIKit
import WebKit
import RxSwift
import RxCocoa

final class DebtsCheckWebView: UIView {
    
    private lazy var webView = makeWebView()
    private let tokenRelay = PublishRelay<String>()
    private let cookiesRelay = PublishRelay<String>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let js = """
    function checkCaptcha() {
        grecaptcha.execute('6LevzOUUAAAAAGjAekCNws95tBDm5m69m5LT4L7X', {action: 'view_salary_debt'}).then(function(token) {
                window.webkit.messageHandlers.\(DebtsCheckWebView.handler).postMessage(token);
            });
    }
    
    window.setTimeout(checkCaptcha, 5000);
    """
}

extension DebtsCheckWebView {
    
    var loadCaptcha: Binder<Void> {
        Binder(self) { base, _ in
            base.load()
        }
    }
    
    var captcha: Signal<DebtsCheckCaptcha> {
        Observable.zip(tokenRelay, cookiesRelay) { .init(token: $0, cookies: $1) }
            .asSignal(onErrorSignalWith: .empty())
    }
}

extension DebtsCheckWebView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { [weak self] value in
            let cookies = value.reduce(into: "") {
                $0.append("\($1.name):\($1.value);")
            }
            
            self?.cookiesRelay.accept(cookies)
        }
    }
}

private extension DebtsCheckWebView {
    func initialize() {
        webView.navigationDelegate = self
    }
    
    func load() {
        webView.load(URLRequest(url: URL(string: GlobalDefinitions.searchDebtors)!))
    }
}

// MARK: Make constraints
private extension DebtsCheckWebView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}

extension DebtsCheckWebView: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == Self.handler, let token = message.body as? String {
            tokenRelay.accept(token)
        }
    }
}

// MARK: Lazy initialization
private extension DebtsCheckWebView {
    func makeWebView() -> WKWebView {
        let config = WKWebViewConfiguration()
        let script = WKUserScript(source: self.js, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let handler = JSMessageHandler(delegate: self)
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        config.userContentController.addUserScript(script)
        config.userContentController.add(handler, name: Self.handler)
        config.preferences = preferences
        
        let view = WKWebView(frame: .zero, configuration: config)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    static let handler = "onNativeCalled"
}

class JSMessageHandler : NSObject, WKScriptMessageHandler {
        weak var delegate : WKScriptMessageHandler?
        init(delegate: WKScriptMessageHandler) {
            self.delegate = delegate
            super.init()
        }
    
        func userContentController(_ ucc: WKUserContentController,
            didReceive message: WKScriptMessage) {
                self.delegate?.userContentController(ucc, didReceive: message)
        }
}
