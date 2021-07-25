//
//  SplashView.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 24.07.2021.
//
import UIKit

final class SplashView: UIView {
    
    private lazy var logo = makeLogo()
    private lazy var label = makeLabel()
    private lazy var loader = makeLoader()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension SplashView {
    func initialize() {
        backgroundColor = UIColor(integralRed: 0, green: 91, blue: 187)
    }
}

// MARK: Make constraints
private extension SplashView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            logo.topAnchor.constraint(equalTo: topAnchor, constant: 100.scale),
            logo.centerXAnchor.constraint(equalTo: centerXAnchor),
            logo.heightAnchor.constraint(equalToConstant: 120.scale),
            logo.widthAnchor.constraint(equalTo: logo.heightAnchor)
        ])
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 40.scale),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10.scale),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10.scale)
        ])
        
        NSLayoutConstraint.activate([
            loader.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -160.scale),
            loader.centerXAnchor.constraint(equalTo: centerXAnchor),
            loader.heightAnchor.constraint(equalToConstant: 20.scale),
            loader.widthAnchor.constraint(equalTo: loader.heightAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension SplashView {
    func makeLogo() -> UIImageView {
        let view = UIImageView()
        view.image = UIImage(named: "Logo")
        view.contentMode = .scaleAspectFit
        view.layer.cornerRadius = 60.scale
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.attributedText = "splash_text".localized.attributed(with: .title)
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLoader() -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.startAnimating()
        view.style = .medium
        view.color = .white
        addSubview(view)
        return view
    }
}

private extension TextAttributes {
    static let title = TextAttributes()
        .font(UIFont.systemFont(ofSize: 30.scale))
        .textAlignment(.center)
        .textColor(UIColor(integralRed: 255, green: 213, blue: 0))
}
