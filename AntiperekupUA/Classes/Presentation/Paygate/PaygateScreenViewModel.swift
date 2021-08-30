//
//  PaygateScreenViewModel.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 26.08.2021.
//

import RxSwift
import RxCocoa

final class PaygateScreenViewModel {
    private lazy var purchaseManager = PurchaseManagerCore()
    private lazy var productIndicator = RxActivityIndicator()
    private lazy var productBuyingIndicator = RxActivityIndicator()
    
    typealias Products = (one: PaygateProductModel, six: PaygateProductModel)
}

extension PaygateScreenViewModel {
    struct Input {
        let productId: Signal<String>
        let didTapRestore: Signal<Void>
    }
    
    struct Output {
        let products: Driver<Products>
        let productIsLoading: Driver<Bool>
        let productIsBuying: Driver<Bool>
        let productBuyedSignal: Signal<Void>
        let errorMessage: Signal<String>
    }
    
    func configure(input: Input) -> Output {
        
        let productsResult = getProducts()
            .share(replay: 1)
        
        let products = productsResult
            .compactMap { $0.element }
            .asDriver(onErrorDriveWith: .empty())
        
        let buyProduct = buyProduct(productId: input.productId)
            .share(replay: 1)
        
        let restorePurchases = restorePurchase(restoreSignal: input.didTapRestore)
            .share(replay: 1)
        
        let buyProductError = buyProduct
            .compactMap { result -> String? in
                guard result?.status == false else { return nil }
                return result?.errorMessage ?? "error_purchaise".localized
            }
        
        let productBuyedSignal = Observable
            .merge(
                restorePurchases.compactMap { $0.isEmpty ? nil : () },
                buyProduct.compactMap { $0?.status == true ? () : nil }
            )
            .asSignal(onErrorSignalWith: .empty())
        
        let errorMessage = Observable
            .merge(
                buyProductError,
                restorePurchases.compactMap { $0.isEmpty ? "subscribe_not_found".localized : nil },
                buyProduct.compactMap { $0?.status == false ? "subscribe_not_found".localized : nil }
            )
            .asSignal(onErrorSignalWith: .empty())
        
        return Output(
            products: products,
            productIsLoading: productIndicator.asDriver(),
            productIsBuying: productBuyingIndicator.asDriver(),
            productBuyedSignal: productBuyedSignal,
            errorMessage: errorMessage
        )
    }
}

// MARK: Private
private extension PaygateScreenViewModel {
    func getProducts() -> Observable<Event<Products>> {
        purchaseManager.getProducts()
            .asObservable()
            .compactMap { products -> Products? in
                guard
                    let sixMonthProduct = products.first(where: { $0.product.subscriptionPeriod?.numberOfUnits == 6 && $0.product.subscriptionPeriod?.unit == .month })?.product,
                    let oneMonthProduct = products.first(where: { $0.product.subscriptionPeriod?.numberOfUnits == 1 && $0.product.subscriptionPeriod?.unit == .month })?.product
                else {
                    return nil
                }
                
                let formatter = NumberFormatter()
                formatter.numberStyle = .currency
                formatter.roundingMode = .up
                formatter.maximumFractionDigits = 0
                formatter.locale = sixMonthProduct.priceLocale
                
                let one = PaygateProductModel(
                    sale: 0,
                    title: String(format: "month_1_cost".localized, formatter.string(from: NSDecimalNumber(decimal: oneMonthProduct.price as Decimal))!),
                    subtitle: String(format: "r_month".localized, formatter.string(from: NSDecimalNumber(decimal: oneMonthProduct.price as Decimal))!),
                    identifier: oneMonthProduct.productIdentifier,
                    isSelected: false
                )
                
                let sixPriceInMonth = formatter.string(from: NSDecimalNumber(decimal: sixMonthProduct.price as Decimal / 6))
                
                let six = PaygateProductModel(
                    sale: Int((1 - Double(truncating: sixMonthProduct.price) / (Double(truncating: oneMonthProduct.price) * 6)) * 100),
                    title: String(format: "month_6_cost".localized, formatter.string(from: NSDecimalNumber(decimal: sixMonthProduct.price as Decimal))!),
                    subtitle: String(format: "r_month".localized, sixPriceInMonth!),
                    identifier: sixMonthProduct.productIdentifier,
                    isSelected: true
                )
                
                
                return (one: one, six: six)
            }
            .materialize()
            .trackActivity(productIndicator)
    }
    
    func buyProduct(productId: Signal<String>) -> Observable<CheckPaygateStatusModel?> {
        return productId
            .asObservable()
            .flatMapFirst { [weak self] id -> Observable<CheckPaygateStatusModel?> in
                guard let self = self else { return .empty() }
                
                return self.purchaseManager
                    .buyProduct(with: id)
                    .asObservable()
                    .flatMap { [weak self] result -> Observable<CheckPaygateStatusModel?> in
                        guard let self = self else { return .empty() }
                        switch result {
                        case .cancelled:
                            return .just(nil)
                        case let .completed(id):
                            return self.purchaseManager.validateReceipt(with: id)
                                .asObservable()
                        }
                    }
                    .catchAndReturn(nil)
                    .trackActivity(self.productBuyingIndicator)
            }
    }
    
    func restorePurchase(restoreSignal: Signal<Void>) -> Observable<[CheckPaygateStatusModel]> {
        restoreSignal
            .asObservable()
            .withUnretained(self)
            .flatMapFirst { base, _ -> Observable<[CheckPaygateStatusModel]> in
                return base.purchaseManager.restorePurchase()
                    .asObservable()
                    .withUnretained(base)
                    .flatMap { base, productIds -> Single<[CheckPaygateStatusModel]> in
                        let requests = productIds.map { base.purchaseManager.validateReceipt(with: $0).catchAndReturn(nil) }
                        return Single
                            .zip(requests)
                            .map { $0.compactMap { $0 } }
                    }
                    .catchAndReturn([])
            }
    }
}
