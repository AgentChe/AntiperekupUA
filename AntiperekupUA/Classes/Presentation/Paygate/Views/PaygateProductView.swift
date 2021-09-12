//
//  PaygateProductView.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 26.08.2021.
//
import UIKit
import RxSwift
import RxCocoa

final class PaygateProductView: UIView {
    
    private lazy var container = makeContainer()
    private lazy var titleLabel = makeTitle()
    private lazy var subtitleLabel = makeSubtitle()
    private lazy var saleView = makeSaleView()
    
    private let productIdRelay = BehaviorRelay<String?>(value: nil)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PaygateProductView {
    func setup(product: PaygateProductModel) {
        titleLabel.text = product.title
        subtitleLabel.text = product.subtitle
        
        titleLabel.textColor = product.isSelected
            ? .white
            : UIColor(integralRed: 2, green: 2, blue: 2)

        subtitleLabel.textColor = product.isSelected
            ? .white
            : UIColor(integralRed: 2, green: 2, blue: 2)

        container.backgroundColor = product.isSelected
            ? UIColor(integralRed: 0, green: 91, blue: 187)
            : UIColor(integralRed: 0, green: 91, blue: 187, alpha: 0.1)
        
        saleView.setup(for: product.sale)
        saleView.isHidden = product.sale == 0
        productIdRelay.accept(product.identifier)
    }
    
    var productId: Signal<String> {
        container.rx.tap
            .withLatestFrom(productIdRelay)
            .compactMap { $0 }
            .asSignal(onErrorSignalWith: .empty())
    }
}

// MARK: Make constraints
private extension PaygateProductView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor, constant: 8.scale),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8.scale)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12.scale),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 28.scale),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -28.scale)
        ])
        
        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7.scale),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12.scale)
        ])
        
        NSLayoutConstraint.activate([
            saleView.topAnchor.constraint(equalTo: topAnchor),
            saleView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            saleView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -15.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension PaygateProductView {
    func makeContainer() -> UIButton {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 0.5.scale
        view.layer.borderColor = UIColor(integralRed: 0, green: 91, blue: 187).cgColor
        view.layer.cornerRadius = 10.scale
        addSubview(view)
        return view
    }
    
    func makeTitle() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = Fonts.SFProDisplay.font(weight: .W500, size: 18.scale)
        container.addSubview(view)
        return view
    }
    
    func makeSubtitle() -> UILabel {
        let view = UILabel()
        view.font = Fonts.SFProDisplay.font(weight: .W400, size: 13.scale)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeSaleView() -> PaygateSaleView {
        let view = PaygateSaleView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
