//
//  ScreenLoadingView.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 29.08.2021.
//
import UIKit

final class ScreenLoadingView: UIView {
    
    private lazy var loader = makeLoader()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black.withAlphaComponent(0.1)
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Make constraints
private extension ScreenLoadingView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            loader.centerYAnchor.constraint(equalTo: centerYAnchor),
            loader.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension ScreenLoadingView {
    func makeLoader() -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.style = .medium
        view.color = .black
        view.startAnimating()
        addSubview(view)
        return view
    }
}

