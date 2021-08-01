//
//  OnboardingBaseView.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 20.07.2021.
//
import UIKit

extension OnboardingBaseView {
    
    enum OnboardingType {
        case info
        case fee
        case base
        case taxi
    }
}

final class OnboardingBaseView: UIView {
    
    lazy var imageView = makeImageView()
    lazy var labelView = makeLabel()
    lazy var nextButton = makeNextButton()
    
    private var nextAction: (() -> Void)?
    
    convenience init(viewType: OnboardingType, nextAction: (() -> Void)? = nil) {
        self.init()
        imageView.image = viewType.image
        labelView.text = viewType.text
        self.nextAction = nextAction
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension OnboardingBaseView {
    func initialize() {
        backgroundColor = UIColor(integralRed: 0, green: 91, blue: 187)
    }
    
    @objc func nextTap() {
        nextAction?()
    }
}

// MARK: Make constraints
private extension OnboardingBaseView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 84.scale),
            imageView.bottomAnchor.constraint(equalTo: labelView.topAnchor, constant: -64)
        ])
        
        NSLayoutConstraint.activate([
            labelView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 52.scale),
            labelView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -52.scale),
            labelView.topAnchor.constraint(equalTo: bottomAnchor, constant: -204)
        ])
        
        NSLayoutConstraint.activate([
            nextButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32.scale),
            nextButton.heightAnchor.constraint(equalToConstant: 28.scale),
            nextButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -68.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension OnboardingBaseView {
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .center
        view.numberOfLines = 0
        view.textColor = .white
        addSubview(view)
        return view
    }
    
    func makeNextButton() -> UIButton {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = UIColor(integralRed: 255, green: 213, blue: 0)
    
        view.setTitleColor(UIColor(integralRed: 255, green: 213, blue: 0), for: .normal)
        view.setTitle("next".localized, for: .normal)
        view.setImage(UIImage(named: "Onboarding.Next"), for: .normal)
        // Не подойдет, если локализация будет для языка справа налево
        view.semanticContentAttribute = .forceRightToLeft
        view.imageEdgeInsets.left = 8
        
        view.addTarget(self, action: #selector(nextTap), for: .touchUpInside)
        addSubview(view)
        return view
    }
}

private extension OnboardingBaseView.OnboardingType {
    var image: UIImage? {
        switch self {
        case .info:
            return UIImage(named: "Onboarding.Slide1")
        case .fee:
            return UIImage(named: "Onboarding.Slide2")
        case .base:
            return UIImage(named: "Onboarding.Slide3")
        case .taxi:
            return UIImage(named: "Onboarding.Slide4")
        }
    }
    
    var text: String {
        switch self {
        case .info:
            return "intro_text1".localized
        case .fee:
            return "intro_text2".localized
        case .base:
            return "intro_text3".localized
        case .taxi:
            return "intro_text4".localized
        }
    }
}
