//
//  PurchaseManagerCore.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 05.08.2021.
//

import Foundation
import RxSwift
import Firebase

final class PurchaseManagerCore {
    private lazy var iapManager = IAPManagerCore()
    
    func isActiveSubscription() -> Single<Bool> {
        let request = GetPaygateRequest(ssad: UIDevice.idfv ?? "")
        
        return RestAPITransport()
            .callServerApi(requestBody: request)
            .map(GetPaygateRequestMapper.map(from:))
    }
    
    func buyProduct(with id: String) -> Single<IAPActionResult> {
        iapManager.buyProduct(with: id)
    }
    
    func validateReceipt(with productId: String) -> Single<CheckPaygateStatusModel?> {
        let receipt = iapManager.retrieveReceipt(forceUpdate: false)
        
        return receipt
            .flatMap { receipt -> Single<CheckPaygateStatusModel?> in
                guard let receipt = receipt else { return .just(nil) }
                
                let request = CheckPaygateStatusRequest(
                    token: receipt,
                    productId: productId
                )
                
                return RestAPITransport()
                    .callServerApi(requestBody: request)
                    .map(CheckPaygateStatusModel.init(from:))
            }
    }
    
    func getProducts() -> Single<[IAPProduct]> {
        iapManager.obtainProducts(ids: getProductIDs())
    }
    
    func restorePurchase() -> Single<[String]> {
        let productIds = getProductIDs()
        return iapManager.restorePurchases()
            .map { purchases -> [String] in
                purchases.compactMap { productIds.contains($0.productId) ? $0.productId : nil }
            }
    }
}

private extension PurchaseManagerCore {
    func getProductIDs() -> [String] {
        guard let url = Bundle.main.url(forResource: "IAP_ProductIDs", withExtension: "plist") else { return [] }
        do {
            let data = try Data(contentsOf: url)
            let productIDs = try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil) as? [String] ?? []
            return productIDs
        } catch {
            return []
        }
    }
}
