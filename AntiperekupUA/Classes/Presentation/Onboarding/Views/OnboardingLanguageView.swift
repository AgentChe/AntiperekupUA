//
//  OnboardingLanguageView.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 21.07.2021.
//
import UIKit
import RxSwift
import RxCocoa

final class OnboardingLanguageView: UIView {
    
    private lazy var titleLabel = makeTitleLabel()
    private lazy var russianLanguage = makeButton(title: "russian".localized)
    private lazy var ukraineLanguage = makeButton(title: "ukraine".localized)
    private lazy var termsLabel = makeTermsLabel()
    private lazy var startButton = makeStartButton()
    var openURL: ((URL) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension OnboardingLanguageView {
    var selectedLanguage: Observable<LanguageModel> {
        Observable<LanguageModel>
            .merge(
                russianLanguage.rx.tap.map { .russian },
                ukraineLanguage.rx.tap.map { .ukraine }
            )
            .startWith(.ukraine)
            .do(onNext: { [weak self] language in
                let initialColor = UIColor(integralRed: 77, green: 140, blue: 207)
                let selectedColor = UIColor(integralRed: 255, green: 213, blue: 0)
                
                switch language {
                case .russian:
                    self?.russianLanguage.isSelected = true
                    self?.ukraineLanguage.isSelected = false
                    self?.russianLanguage.backgroundColor = selectedColor
                    self?.ukraineLanguage.backgroundColor = initialColor
                case .ukraine:
                    self?.russianLanguage.isSelected = false
                    self?.ukraineLanguage.isSelected = true
                    self?.russianLanguage.backgroundColor = initialColor
                    self?.ukraineLanguage.backgroundColor = selectedColor
                }
            })
    }
    
    var didTapStart: Signal<Void> {
        startButton.rx.tap.asSignal()
    }
}

private extension OnboardingLanguageView {
    func initialize() {
        backgroundColor = UIColor(integralRed: 0, green: 91, blue: 187)
    }
    
    @objc func didTapTermsOfService(sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel, let text = label.text as NSString? else {
            return
        }
        
        let termsRange = text.range(of: "privacy_policy_link".localized)
        
        var url: URL?

        if sender.didTapAttributedTextInLabel(label: label, inRange: termsRange) {
            url = URL(string: GlobalDefinitions.termsOfServiceUrl)
        }
        
        guard let termsUrl = url else {
            return
        }
        
        openURL?(termsUrl)
    }
}

// MARK: Make constraints
private extension OnboardingLanguageView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 136.scale),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            ukraineLanguage.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24.scale),
            ukraineLanguage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25.scale),
            ukraineLanguage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25.scale),
            ukraineLanguage.heightAnchor.constraint(equalToConstant: 60.scale)
        ])
        
        NSLayoutConstraint.activate([
            russianLanguage.topAnchor.constraint(equalTo: ukraineLanguage.bottomAnchor, constant: 15.scale),
            russianLanguage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25.scale),
            russianLanguage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25.scale),
            russianLanguage.heightAnchor.constraint(equalToConstant: 60.scale)
        ])
        
        NSLayoutConstraint.activate([
            termsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 52.scale),
            termsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -52.scale),
            termsLabel.topAnchor.constraint(equalTo: bottomAnchor, constant: -204.scale)
        ])
        
        NSLayoutConstraint.activate([
            startButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32.scale),
            startButton.heightAnchor.constraint(equalToConstant: 28.scale),
            startButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -68.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension OnboardingLanguageView {
    func makeTitleLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = "choose_language".localized
        view.textColor = .white
        view.textAlignment = .center
        addSubview(view)
        return view
    }
    
    func makeButton(title: String) -> UIButton {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle(title, for: .normal)
        view.layer.cornerRadius = 14.scale
        view.setTitleColor(.white, for: .normal)
        view.setTitleColor(UIColor(integralRed: 77, green: 140, blue: 207), for: .selected)
        addSubview(view)
        return view
    }
    
    func makeTermsLabel() -> UILabel {
        let view = UILabel()
        let attrs = TextAttributes()
            .font(UIFont.systemFont(ofSize: 16.scale))
            .lineHeight(28.scale)
            .textColor(.white)
            .textAlignment(.center)
            .dictionary
        
        var underlineAtts = attrs
        underlineAtts[.underlineStyle] = NSUnderlineStyle.single.rawValue
        
        let continueAttr = NSAttributedString(
            string: "privacy_policy_title".localized,
            attributes: attrs
        )
        let termsAttr = NSAttributedString(
            string: "privacy_policy_link".localized,
            attributes: underlineAtts
        )
        
        let attributedText = NSMutableAttributedString()
        attributedText.append(continueAttr)
        attributedText.append(termsAttr)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTermsOfService))
        
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        view.attributedText = attributedText
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        addSubview(view)
        return view
    }
    
    func makeStartButton() -> UIButton {
        let view = UIButton()
        view.setTitle("start".localized, for: .normal)
        view.setTitleColor(UIColor(integralRed: 255, green: 213, blue: 0), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}

private extension TextAttributes {
    static let termsButtonAttr = TextAttributes()
        .textColor(.white)
        .font(UIFont.systemFont(ofSize: 16.scale))
        .underlineStyle(.single)
}
