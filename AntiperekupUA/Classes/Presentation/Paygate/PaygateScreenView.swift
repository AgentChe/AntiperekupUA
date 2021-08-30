//
//  PaygateScreenView.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 26.08.2021.
//
import UIKit

final class PaygateScreenView: UIView {
    
    private lazy var title = makeTitle()
    private lazy var stackView = makeStackView()
    lazy var sixMonthProduct = makeProductView()
    lazy var monthProduct = makeProductView()
    lazy var restoreButton = makeRestore()
    lazy var productLoader = makeProductLoader()
    lazy var loadingView = makeLoadingView()
    private lazy var termsLabel = makeTermsLabel()
    
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

private extension PaygateScreenView {
    func initialize() {
        backgroundColor = .white
        stackView.addArrangedSubview(makeCheckView(title: "premium_access_info_1".localized))
        stackView.addArrangedSubview(makeCheckView(title: "premium_access_info_2".localized))
        stackView.addArrangedSubview(makeCheckView(title: "premium_access_info_3".localized))
    }
    
    @objc func didTapTermsOfService(sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel, let text = label.text as NSString? else {
            return
        }
        
        let termsRange = text.range(of: "subscription_info_2_2".localized)
        
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
private extension PaygateScreenView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.topAnchor, constant: 50.scale),
            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            title.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 24.scale),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            sixMonthProduct.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 42.scale),
            sixMonthProduct.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            sixMonthProduct.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -31.scale),
            sixMonthProduct.heightAnchor.constraint(equalToConstant: 84.scale)
        ])
        
        NSLayoutConstraint.activate([
            monthProduct.topAnchor.constraint(equalTo: sixMonthProduct.bottomAnchor),
            monthProduct.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            monthProduct.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -31.scale),
            monthProduct.heightAnchor.constraint(equalToConstant: 84.scale)
        ])
        
        NSLayoutConstraint.activate([
            productLoader.topAnchor.constraint(equalTo: sixMonthProduct.topAnchor),
            productLoader.bottomAnchor.constraint(equalTo: monthProduct.bottomAnchor),
            productLoader.leadingAnchor.constraint(equalTo: leadingAnchor),
            productLoader.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            restoreButton.topAnchor.constraint(greaterThanOrEqualTo: monthProduct.bottomAnchor, constant: 16.scale),
            restoreButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15.scale),
            restoreButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15.scale),
            restoreButton.heightAnchor.constraint(equalToConstant: 20.scale)
        ])
        
        NSLayoutConstraint.activate([
            termsLabel.topAnchor.constraint(lessThanOrEqualTo: restoreButton.bottomAnchor, constant: 24.scale),
            termsLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -35.scale),
            termsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15.scale),
            termsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15.scale)
        ])
        
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension PaygateScreenView {
    func makeTitle() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        view.attributedText = "premium_access_subtitle".localized.attributed(with: .title)
        addSubview(view)
        return view
    }
    
    func makeCheckView(title: String) -> PaygateCheckView {
        let view = PaygateCheckView()
        view.setup(for: title)
        return view
    }
    
    func makeStackView() -> UIStackView {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 24.scale
        addSubview(view)
        return view
    }
    
    func makeProductView() -> PaygateProductView {
        let view = PaygateProductView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        addSubview(view)
        return view
    }
    
    func makeProductLoader() -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.startAnimating()
        view.style = .medium
        view.color = UIColor(integralRed: 112, green: 160, blue: 172)
        addSubview(view)
        return view
    }
    
    func makeRestore() -> UIButton {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setAttributedTitle("restore_purchase".localized.attributed(with: .restore), for: .normal)
        view.backgroundColor = .clear
        addSubview(view)
        return view
    }
    
    func makeTermsLabel() -> UILabel {
        let view = UILabel()
        let attrs = TextAttributes()
            .font(Fonts.SFProDisplay.font(weight: .W400, size: 11.scale))
            .lineHeight(15.scale)
            .textColor(UIColor(integralRed: 2, green: 2, blue: 2))
            .dictionary
        
        var underlineAtts = attrs
        underlineAtts[.underlineStyle] = NSUnderlineStyle.single.rawValue
        
        let continueAttr = NSAttributedString(
            string: "subscription_info_2_1".localized,
            attributes: attrs
        )
        let termsAttr = NSAttributedString(
            string: "subscription_info_2_2".localized,
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
    
    func makeLoadingView() -> PaygateScreenLoadingView {
        let view = PaygateScreenLoadingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        addSubview(view)
        return view
    }
}

private extension TextAttributes {
    static let title = TextAttributes()
        .font(Fonts.SFProDisplay.font(weight: .W700, size: 20))
        .lineHeight(41.scale)
        .textColor(.black)
        .textAlignment(.center)
    
    static let restore = TextAttributes()
        .font(Fonts.SFProDisplay.font(weight: .W400, size: 15.scale))
        .lineHeight(18.scale)
        .textAlignment(.center)
        .textColor(UIColor(integralRed: 0, green: 91, blue: 187))
}
