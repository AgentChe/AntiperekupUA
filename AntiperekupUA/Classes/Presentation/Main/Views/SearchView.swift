//
//  SearchView.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 27.07.2021.
//
import UIKit
import RxSwift
import RxCocoa

extension SearchView {
    enum FieldType {
        case regNumber
        case vin
        case tecnicalPassport
    }
}

final class SearchView: UIView {
    
    private lazy var searchField = makeSearchField()
    private lazy var searchButton = makeSearchButton()
    private lazy var containerView = makeContainer()
    
    private var fieldType: FieldType?
    private let didTapDone = PublishRelay<Void>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SearchView {
    var searchText: Observable<String?> {
        searchField.rx.text.asObservable()
    }
    
    var didTapSearch: Signal<Void> {
        Signal
            .merge(
                searchButton.rx.tap.asSignal(),
                didTapDone.asSignal()
            )
        
    }
    
    var searchModel: Binder<FieldType> {
        Binder(self) { base, model in
            base.searchField.placeholder = model.placeholder
            base.fieldType = model
            if let text = base.searchField.text {
                base.searchField.text = nil
                base.searchField.insertText(text)
            }
        }
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

extension SearchView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var fieldType: SearchValueFormatter.FieldType? {
            switch self.fieldType {
            case .regNumber:
                return .regNumber
            case .vin:
                return .vin
            case .tecnicalPassport:
                return .technicalPassport
            case .none:
                return nil
            }
        }
        return SearchValueFormatter.textField(textField, shouldChangeCharactersIn: range, replacementString: string, fieldType: fieldType)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didTapDone.accept(())
        return true
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
        view.delegate = self
        view.returnKeyType = .done
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

private extension SearchView.FieldType {
    var placeholder: String {
        switch self {
        case .regNumber:
            return "АА1234ТС"
        case .vin:
            return "XTA210990W2395414"
        case .tecnicalPassport:
            return "CXI 399999"
        }
    }
}
