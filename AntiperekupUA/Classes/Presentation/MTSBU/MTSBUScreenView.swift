//
//  MTSBUScreenView.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 12.10.2021.
//
import UIKit

final class MTSBUScreenView: UIView {
    
    lazy var webView = makeWebView()
    lazy var skipButton = makeBottomButton()
    private lazy var stepLabel = makeStepLabel()
    private lazy var descriptionLabel = makeDescriptionLabel()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension MTSBUScreenView {
    func initialize() {
        backgroundColor = UIColor(integralRed: 242, green: 242, blue: 242)
    }
}

// MARK: Make constraints
private extension MTSBUScreenView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            stepLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16.scale),
            stepLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            stepLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: stepLabel.bottomAnchor, constant: 16.scale),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24.scale),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24.scale)
        ])
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: skipButton.topAnchor),
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            skipButton.heightAnchor.constraint(equalToConstant: 48.scale),
            skipButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            skipButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            skipButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension MTSBUScreenView {
    func makeWebView() -> MTSBUWebView {
        let view = MTSBUWebView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeStepLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 3
        view.attributedText = "wait_text".localized.attributed(with: .step)
        addSubview(view)
        return view
    }
    
    func makeDescriptionLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        view.attributedText = "wait_text2".localized.attributed(with: .description)
        addSubview(view)
        return view
    }
    
    func makeBottomButton() -> BottomButtonView {
        let view = BottomButtonView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setup(title: "skip".localized.uppercased(), isHiddenBottomLine: true)
        addSubview(view)
        return view
    }
}

private extension TextAttributes {
    static let step = TextAttributes()
        .font(Fonts.SFProDisplay.font(weight: .W700, size: 17.scale))
        .lineHeight(24.scale)
        .textColor(.black)
    
    static let description = TextAttributes()
        .font(Fonts.SFProText.font(weight: .W400, size: 11.scale))
        .lineHeight(18.scale)
        .textColor(UIColor(integralRed: 142, green: 142, blue: 142))
}
