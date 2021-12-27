//
//  MTSBUWebView.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 12.10.2021.
//
import UIKit
import WebKit
import RxSwift
import RxCocoa

final class MTSBUWebView: UIView {
    
    private lazy var webView = makeWebView()
    private let captchaLoadedRelay = BehaviorRelay<Bool>(value: false)
    private let captchaRelay = PublishRelay<MTSBUCaptcha>()
    private let cookiesRelay = PublishRelay<[HTTPCookie]>()
    private let errorLoadRelay = PublishRelay<Error>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MTSBUWebView {
    var captchaLoaded: Driver<Bool> {
        captchaLoadedRelay.asDriver()
    }
    
    var captcha: Signal<MTSBUCaptcha> {
        captchaRelay.asSignal()
    }
    
    var cookies: Signal<[HTTPCookie]> {
        cookiesRelay.asSignal()
    }
    
    var loadError: Signal<Error> {
        errorLoadRelay.asSignal()
    }
    
    var newCookies: Binder<[HTTPCookie]> {
        Binder(self) { base, cookies in
            
            let group = DispatchGroup()
            
            cookies.forEach { cookie in
                group.enter()
                base.webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie) {
                    group.leave()
                }
            }
            
            group.notify(queue: .main) { [weak base] in
                base?.load()
            }
        }
    }
    
    var retryLoad: Binder<Void> {
        Binder(self) { base, _ in
            base.load()
        }
    }
}

extension MTSBUWebView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { [cookiesRelay, captchaLoadedRelay] cookies in
            if cookies.contains(where: { $0.name.lowercased().contains(Constants.cookieName) }) {
                cookiesRelay.accept(cookies)
                webView.evaluateJavaScript(Constants.showCaptcha, completionHandler: { [captchaLoadedRelay] _, _ in
                    captchaLoadedRelay.accept(true)
                })
                webView.evaluateJavaScript(Constants.captchaFunc)
            } else {
                cookiesRelay.accept([])
                captchaLoadedRelay.accept(false)
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        errorLoadRelay.accept(error)
    }
}

extension MTSBUWebView: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if
            message.name == Constants.tokenResult,
            let elements = message.body as? [String: Any],
            let captcha = elements[Constants.captchaKey] as? String,
            let token = elements[Constants.tokenKey] as? String
        {
            WKWebsiteDataStore.default().httpCookieStore.getAllCookies { [captchaRelay] cookies in
                let cookiesString = cookies.reduce(into: "") { $0.append("\($1.name)=\($1.value); ") }
                let captchaModel = MTSBUCaptcha(
                    token: token,
                    captchaCode: captcha,
                    cookiesString: cookiesString
                )
                captchaRelay.accept(captchaModel)
            }
        }
    }
}

private extension MTSBUWebView {
    func initialize() {
        webView.navigationDelegate = self
        load()
    }
    
    func load() {
        if let url = URL(string: GlobalDefinitions.mtsbu) {
            webView.load(URLRequest(url: url))
            captchaLoadedRelay.accept(false)
        }
    }
}

// MARK: Make constraints
private extension MTSBUWebView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension MTSBUWebView {
    func makeWebView() -> WKWebView {
        let config = WKWebViewConfiguration()
        let script = WKUserScript(source: Constants.jsInjection, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let handler = JSMessageHandler(delegate: self)
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        config.userContentController.addUserScript(script)
        config.userContentController.add(handler, name: Constants.tokenResult)
        config.preferences = preferences
        
        let view = WKWebView(frame: .zero, configuration: config)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}

private extension MTSBUWebView {
    enum Constants {
        static let captchaFunc = "captchaFunc()"
        static let cookieName = "aspnetcore"
        static let tokenResult = "onNativeCalled"
        static let captchaKey = "captcha"
        static let tokenKey = "token"
        static let jsInjection = """
        function \(Self.captchaFunc) {
            var int;
            int = setInterval(function() {
                if($('#g-recaptcha-response').val().length > 0 && $('input[name=__RequestVerificationToken]').val().length > 0) {
                    window.webkit.messageHandlers.\(Self.tokenResult).postMessage({
                        \(Self.captchaKey): $('#g-recaptcha-response').val(),
                        \(Self.tokenKey): $('input[name=__RequestVerificationToken]').val()
                    });
                    clearInterval(int);
                }
            },1000);
        };
        """
        static let showCaptcha = """
        (function() {
                $('.forms_wrap').addClass('active');
                $('.form-wrap-absolute').addClass('active');
                $('#carNumber').addClass('active');
                $('#submitBtn').click();
        })();
        """
    }
}
