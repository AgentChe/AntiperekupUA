//
//  MainSearchHeaderView.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 27.07.2021.
//
import UIKit
import RxSwift

final class MainSearchHeaderView: UIView {
    
    private lazy var searchView = makeSearchView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MainSearchHeaderView {
    var searchText: Observable<String> {
        searchView.searchText
    }
    
    var placeholder: Binder<String?> {
        searchView.placeholder
    }
    
    var isError: Binder<Bool> {
        return searchView.isError
    }
}

// MARK: Make constraints
private extension MainSearchHeaderView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            searchView.topAnchor.constraint(equalTo: topAnchor),
            searchView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16.scale),
            searchView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            searchView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            searchView.heightAnchor.constraint(equalToConstant: 50.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension MainSearchHeaderView {
    func makeSearchView() -> SearchView {
        let view = SearchView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(integralRed: 250, green: 252, blue: 254)
        addSubview(view)
        return view
    }
}
