//
//  SearchView.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 27.07.2021.
//
import UIKit
import RxSwift

final class SearchView: UIView {
    
    private lazy var searchField = makeSearchField()
    private lazy var searchButton = makeSearchButton()
    private lazy var containerView = makeContainer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SearchView {
    var searchText: Observable<String> {
        searchButton.rx.tap
            .withLatestFrom(searchField.rx.text)
            .compactMap { $0 }
    }
    
    var placeholder: Binder<String?> {
        searchField.rx.placeholder
    }
    
    var isError: Binder<Bool> {
        Binder(self) { base, isError in
            let errorColor = UIColor(integralRed: 205, green: 47, blue: 30)
            base.searchField.textColor = isError ? errorColor : .black
            base.containerView.layer.borderColor = isError
                ? errorColor.cgColor
                : UIColor(integralRed: 125, green: 172, blue: 221).cgColor
        }
    }
}

// MARK: Make constraints
private extension SearchView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14.scale),
            searchField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -14.scale),
            searchField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 14.scale),
            searchField.trailingAnchor.constraint(equalTo: searchButton.leadingAnchor, constant: -14.scale)
        ])
        
        NSLayoutConstraint.activate([
            searchButton.topAnchor.constraint(equalTo: containerView.topAnchor),
            searchButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            searchButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            searchButton.heightAnchor.constraint(equalTo: searchButton.widthAnchor),
            searchButton.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension SearchView {
    func makeSearchButton() -> UIButton {
        let view = UIButton()
        view.setImage(UIImage(named: "Main.Search"), for: .normal)
        view.tintColor = UIColor(integralRed: 0, green: 91, blue: 187)
        view.backgroundColor = UIColor(integralRed: 255, green: 213, blue: 0)
        view.layer.cornerRadius = 10.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSearchField() -> UITextField {
        let view = UITextField()
        view.autocapitalizationType = .allCharacters
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.overrideUserInterfaceStyle = .light
        addSubview(view)
        return view
    }
    
    func makeContainer() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 10.scale
        view.layer.borderWidth = 0.5.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
