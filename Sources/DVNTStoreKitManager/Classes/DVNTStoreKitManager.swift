//
//  DVNTAlamofireWrapper.swift
//
//
//  Created by Raúl Vidal Muiños on 23/6/20.
//  Copyright © 2020 Raúl Vidal Muiños. All rights reserved.
//

import UIKit
import StoreKit
import DVNTAlertManager

public protocol DVNTStoreKitManagerDelegate
{
    func storeKitManagerPurchaseDidFail(error: Error?)
    func storekitManagerPurchaseUserUnableToMakePayments()
    func storeKitManagerProductsListDidChange(storeKitManager: DVNTStoreKitManager)
}

public class DVNTStoreKitManager: NSObject
{
    public static let shared = DVNTStoreKitManager()
    
    public final var delegate: DVNTStoreKitManagerDelegate?
    
    private final let alertManager = DVNTAlertManager.shared
    
    private final var userApplicationId: String?
    private final var shouldAddStorePayment = true
    
    private final var products: [SKProduct] = [] {
        didSet {
            self.delegate?.storeKitManagerProductsListDidChange(storeKitManager: self)
        }
    }
    private final var inAppPurchaseIdentifiers: [String] = [] {
        didSet {
            let newProductIdentifiers = Set(self.inAppPurchaseIdentifiers).symmetricDifference(Set(oldValue))
            self.performRequestForProductIdentifiers(newProductIdentifiers)
        }
    }
    
    override init()
    {
        super.init()
        
        self.products.removeAll()
        self.inAppPurchaseIdentifiers.removeAll()
        
        SKPaymentQueue.default().add(self)
    }
    
    // MARK: - Public setters
    
    public final func setUserApplicationId(_ value: String?) { self.userApplicationId = value }
    public final func setShouldAddStorePayment(_ value: Bool) { self.shouldAddStorePayment = value }
    public final func setInAppPurchaseIdentifier(_ value: String) { self.setInAppPurchaseIdentifiers([value]) }
    
    // MARK: - Public getters
    
    public final func getProducts() -> [SKProduct] { return self.products }
    public final func getInAppPurchaseIdentifiers() -> [String] { return self.inAppPurchaseIdentifiers }
    
    // MARK: - Advanced public setters
    
    public final func setInAppPurchaseIdentifiers(_ value: [String])
    {
        if self.inAppPurchaseIdentifiers.isEmpty {
            self.inAppPurchaseIdentifiers = value
        }else{
            print("💰 ⛔️ DVNTStoreKitManager: The array of purchase identifiers has already been initialized. Use 'appendInAppPurchaseIdentifier' instead.")
        }
    }
    
    // MARK: - Advanced public getters
    
    public final func getLocalizedPrice(_ product: SKProduct) -> String
    {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: product.price) ?? "-"
    }
    
    // MARK: - Other methods
    
    public final func appendInAppPurchaseIdentifier(_ value: String)
    {
        let identifiers = self.getInAppPurchaseIdentifiers()
        if !identifiers.contains(value) {
            self.inAppPurchaseIdentifiers.append(value)
        }else{
            print("💰 ⚠️ DVNTStoreKitManager: '\(value)' already existst in the array and it couldn't be added twice.")
        }
    }
    
    public final func appendInAppPurchaseIdentifiers(_ value: [String])
    {
        for identifier in value {
            self.appendInAppPurchaseIdentifier(identifier)
        }
    }
    
    private final func performRequestForProductIdentifiers(_ productIdentifiers: Set<String>)
    {
        print("💰 ⚠️ DVNTStoreKitManager: Initializing some IAPs -> \(productIdentifiers)...")
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
    }
    
    public final func purchaseProduct(_ product: SKProduct)
    {
        self.purchaseProduct(product.productIdentifier)
    }
    
    public final func purchaseProduct(_ productIdentifier: String)
    {
        if SKPaymentQueue.canMakePayments() {
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = productIdentifier
            paymentRequest.applicationUsername = self.userApplicationId
            SKPaymentQueue.default().add(paymentRequest)
        }else{
            print("💰 ⛔️ DVNTStoreKitManager: This user cannot make a payment.")
            self.delegate?.storekitManagerPurchaseUserUnableToMakePayments()
        }
    }
}

// MARK: - SKProductsRequest and SKRequest extension

extension DVNTStoreKitManager: SKProductsRequestDelegate, SKRequestDelegate
{
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse)
    {
        for product in response.products {
            self.products.append(product)
            print("💰 ✅ DVNTStoreKitManager: '\(product.productIdentifier)' has been initialized successfully")
        }
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error)
    {
        print("💰 ⛔️ DVNTStoreKitManager: \(error.localizedDescription)")
    }
}

// MARK: - SKPaymentTransactionObserver extension

extension DVNTStoreKitManager: SKPaymentTransactionObserver
{
    
    public func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool
    {
        return self.shouldAddStorePayment
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction])
    {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                break
            case .purchasing:
                break
            case .deferred:
                break
            case .failed:
                if let error = transaction.error {
                    print("💰 ⛔️ DVNTStoreKitManager: Transaction did fail with error '\(error.localizedDescription)'")
                }else{
                    print("💰 ⛔️ DVNTStoreKitManager: Transaction did fail with an unknown error.")
                }
                
                self.delegate?.storeKitManagerPurchaseDidFail(error: transaction.error)
                self.alertManager.showBasicAlert(title: "Error", message: transaction.error?.localizedDescription ?? "Transaction did fail with an unknown error.")
            case .restored:
                break
            }
        }
    }
}
