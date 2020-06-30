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
import SwiftyReceiptValidator

@objc public protocol DVNTStoreKitManagerDelegate
{
    func storeKitManagerPurchaseDidFail(productIdentifier: String, error: Error?)
    func storeKitManagerPurchaseDidSucced(productIdentifier: String, transactionIdentifier: String?)
    func storeKitManagerActiveSubscriptionDetected(productIdentifier: String, receipt: SRVReceiptInApp)
    func storeKitManagerPurchaseRestoredSuccesfully(productIdentifier: String, transactionIdentifier: String?)
    
    @objc optional func storekitManagerPurchaseUserUnableToMakePayments()
    @objc optional func storeKitManagerSubscriptionValidationDidFinish()
    @objc optional func storeKitManagerStorePurchaseWasRetained(productIdentifier: String)
    @objc optional func storeKitManagerProductsListDidChange(storeKitManager: DVNTStoreKitManager)
}

public class DVNTStoreKitManager: NSObject
{
    public static let shared = DVNTStoreKitManager()
    
    private final let alertManager = DVNTAlertManager.shared
    
    public final var delegate: DVNTStoreKitManagerDelegate?
    public final var isAuthorizedForPayments: Bool { return SKPaymentQueue.canMakePayments() }
    
    private final var secret: String?
    private final var userApplicationId: String?
    private final var shouldAddStorePayment = true
    private final var storedPayments: [SKPayment] = []
    private final var purchasedProductIdentifiers: [String] = []
    private final var isInitialSubscriptionVerificationCompleted = false
    private final let receiptValidator = SwiftyReceiptValidator(configuration: .standard, isLoggingEnabled: false)
    
    private final var products: [SKProduct] = [] {
        didSet {
            self.delegate?.storeKitManagerProductsListDidChange?(storeKitManager: self)
        }
    }
    private final var inAppPurchaseIdentifiers: [String] = [] {
        didSet {
            let newProductIdentifiers = Set(self.inAppPurchaseIdentifiers).symmetricDifference(Set(oldValue))
            self.fetchProducts(newProductIdentifiers)
        }
    }
    
    override init()
    {
        super.init()
        
        self.products.removeAll()
        self.inAppPurchaseIdentifiers.removeAll()
        self.isInitialSubscriptionVerificationCompleted = false
    }
    
    // MARK: - Public setters
    
    public final func setSecret(_ value: String) { self.secret = value }
    public final func setUserApplicationId(_ value: String?) { self.userApplicationId = value }
    public final func setShouldAddStorePayment(_ value: Bool) { self.shouldAddStorePayment = value }
    public final func setInAppPurchaseIdentifier(_ value: String) { self.setInAppPurchaseIdentifiers([value]) }
    
    // MARK: - Public getters
    
    public final func getProducts() -> [SKProduct] { return self.products }
    public final func getInAppPurchaseIdentifiers() -> [String] { return self.inAppPurchaseIdentifiers }
    
    // MARK: - Advanced public setters
    
    public final func setSpinnerAppearance(style: AlertStyleType = .iOS, baseColor: UIColor, inkColor: UIColor, backgroundColor: UIColor)
    {
        self.alertManager.setAlertStyle(style)
        self.alertManager.setInkColor(inkColor)
        self.alertManager.setBaseColor(baseColor)
        self.alertManager.setLoadingViewBackgroundColor(backgroundColor)
    }
    
    public final func setInAppPurchaseIdentifiers(_ value: [String])
    {
        if self.inAppPurchaseIdentifiers.isEmpty {
            self.inAppPurchaseIdentifiers = value
        }else{
            print("💰 ⛔️ DVNTStoreKitManager: The array of purchase identifiers has already been initialized. Use 'appendInAppPurchaseIdentifier' instead.")
        }
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
    
    private final func fetchProducts(_ productIdentifiers: Set<String>)
    {
        print("💰 ⚠️ DVNTStoreKitManager: Fetching some products -> \(productIdentifiers)...")
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
    }
    
    public final func buy(_ product: SKProduct, shouldShowSpinner: Bool = false)
    {
        self.buy(product.productIdentifier, shouldShowSpinner: shouldShowSpinner)
    }
    
    public final func buy(_ productIdentifier: String, shouldShowSpinner: Bool = false)
    {
        #if targetEnvironment(simulator)
        self.alertManager.showBasicAlert(title: "Error", message: "A real device must be used to perform this action.")
        print("💰 ⛔️ DVNTStoreKitManager: Purchases cannot be made using a simultor. Please, connect a real device and try again")
        #else
        guard SKPaymentQueue.default().transactions.last?.transactionState != .purchasing else {
            print("💰 ⛔️ DVNTStoreKitManager: There is another purchase in progress, please wait.")
            return
        }
        if shouldShowSpinner { self.alertManager.showLoadingView(isUserinteractionEnabled: false) }
        if self.isAuthorizedForPayments {
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = productIdentifier
            paymentRequest.applicationUsername = self.userApplicationId
            SKPaymentQueue.default().add(paymentRequest)
        }else{
            print("💰 ⛔️ DVNTStoreKitManager: This user cannot make a payment.")
            self.delegate?.storekitManagerPurchaseUserUnableToMakePayments?()
            DispatchQueue.main.async { self.alertManager.hideLoadingView() }
        }
        #endif
    }
    
    public final func restore(shouldShowSpinner: Bool = false)
    {
        print("💰 ⚠️ DVNTStoreKitManager: Restoring purchases...")
        if shouldShowSpinner { self.alertManager.showLoadingView(isUserinteractionEnabled: false) }
        SKPaymentQueue.default().restoreCompletedTransactions(withApplicationUsername: self.userApplicationId)
    }
    
    public final func isSubscription(_ productId: String) -> Bool
    {
        if let product = self.products.first(where: { $0.productIdentifier == productId }) {
            return self.isSubscription(product)
        }
        return false
    }
    
    public final func isSubscription(_ product: SKProduct) -> Bool
    {
        return product.subscriptionPeriod != nil
    }
    
    private final func validatePurchase(queue: SKPaymentQueue, transaction: SKPaymentTransaction, productId: String, sharedSecret: String?, success: @escaping () -> Void, failure: @escaping (Error?) -> Void)
    {
        print("💰 ⚠️ DVNTStoreKitManager: Validating purchase...")
        let validationRequest = SRVPurchaseValidationRequest(productId: productId, sharedSecret: self.secret)
        self.receiptValidator.validate(validationRequest) { result in
            switch result {
            case .success(_):
                defer {
                    queue.finishTransaction(transaction)
                }
                UserDefaults.standard.set(true, forKey: productId)
                DispatchQueue.main.async { self.alertManager.hideLoadingView() }
                if !self.isSubscription(productId) {
                    self.delegate?.storeKitManagerPurchaseRestoredSuccesfully(productIdentifier: transaction.payment.productIdentifier, transactionIdentifier: transaction.transactionIdentifier)
                }
                print("💰 ✅ DVNTStoreKitManager: Purchase of '\(productId)' validated successfully")
                success()
            case .failure(let error):
                DispatchQueue.main.async { self.alertManager.hideLoadingView() }
                print("💰 ⛔️ DVNTStoreKitManager: Validation of product '\(productId)' did finish with error \(error.localizedDescription)")
                failure(error)
            }
        }
    }
    
    public final func processStoredPayments(shouldShowSpinner: Bool = false)
    {
        if shouldShowSpinner { self.alertManager.showLoadingView(isUserinteractionEnabled: false) }
        for payment in self.storedPayments {
            SKPaymentQueue.default().add(payment)
        }
    }
    
    public final func validateSubscriptions()
    {
        print("💰 ⚠️ DVNTStoreKitManager: Verifying subscriptions...")
        let validationRequest = SRVSubscriptionValidationRequest( sharedSecret: self.secret, refreshLocalReceiptIfNeeded: false, excludeOldTransactions: false, now: Date())
        self.receiptValidator.validate(validationRequest) { result in
            self.isInitialSubscriptionVerificationCompleted = true
            switch result {
            case .success(let response):
                for receipt in response.validSubscriptionReceipts {
                    if !self.purchasedProductIdentifiers.contains(receipt.productId) {
                        self.purchasedProductIdentifiers.append(receipt.productId)
                        self.delegate?.storeKitManagerActiveSubscriptionDetected?(productIdentifier: receipt.productId, receipt: receipt)
                    }
                }
                self.delegate?.storeKitManagerSubscriptionValidationDidFinish?()
                print("💰 ✅ DVNTStoreKitManager: The validation of the subscriptions did finish successfully")
            case .failure(let error):
                DispatchQueue.main.async { self.alertManager.hideLoadingView() }
                self.delegate?.storeKitManagerSubscriptionValidationDidFinish?()
                print("💰 ⛔️ DVNTStoreKitManager: The validation of the subscriptions did finish with error \(error.localizedDescription)")
            }
        }
    }
    
    public final func checkIsPurchased(productId: String, isNonConsumable: Bool) -> Bool?
    {
        if self.isInitialSubscriptionVerificationCompleted {
            return isNonConsumable ? UserDefaults.standard.bool(forKey: productId) : self.purchasedProductIdentifiers.contains(productId)
        }
        return nil
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
        self.validateSubscriptions()
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error)
    {
        print("💰 ⛔️ DVNTStoreKitManager: \(error.localizedDescription)")
    }
    
    public func requestDidFinish(_ request: SKRequest)
    {
        if request is SKProductsRequest {
            SKPaymentQueue.default().add(self)
        }
    }
}

// MARK: - SKPaymentTransactionObserver extension

extension DVNTStoreKitManager: SKPaymentTransactionObserver
{
    public func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool
    {
        if self.shouldAddStorePayment {
            self.alertManager.showLoadingView(isUserinteractionEnabled: false)
        }else{
            self.storedPayments.append(payment)
            self.delegate?.storeKitManagerStorePurchaseWasRetained?(productIdentifier: payment.productIdentifier)
        }
        
        return self.shouldAddStorePayment
    }
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue)
    {
        self.validateSubscriptions()
        DispatchQueue.main.async { self.alertManager.hideLoadingView() }
        print("💰 ✅ DVNTStoreKitManager: Purchases restored successfully")
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error)
    {
        self.validateSubscriptions()
        DispatchQueue.main.async { self.alertManager.hideLoadingView() }
        print("💰 ⛔️ DVNTStoreKitManager: Error while restoring purchases '\(error.localizedDescription)'")
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction])
    {
        for transaction in transactions {
            if transaction.transactionState != .purchasing, transaction.transactionState != .deferred {
                switch transaction.transactionState {
                case .purchased:
                    let productId = transaction.payment.productIdentifier
                    self.validatePurchase(queue: queue, transaction: transaction, productId: productId, sharedSecret: self.secret, success: { () in
                        self.purchasedProductIdentifiers.append(productId)
                        if self.isSubscription(productId) {
                            self.validateSubscriptions()
                        }
                    }, failure: { _ in })
                    break
                case .restored:
                    guard let productId = transaction.original?.payment.productIdentifier else {
                        queue.finishTransaction(transaction)
                        return
                    }
                    self.validatePurchase(queue: queue, transaction: transaction, productId: productId, sharedSecret: self.secret, success: { () in
                        if !self.isSubscription(productId) {
                            self.purchasedProductIdentifiers.append(productId)
                        }
                    }, failure: { _ in })
                    break
                case .failed:
                    if let error = transaction.error as? SKError, error.code != .paymentCancelled, error.code != .unknown {
                        self.alertManager.showBasicAlert(title: "Error", message: transaction.error?.localizedDescription ?? "Transaction did fail with an unknown error.")
                        print(transaction.error != nil ? "💰 ⛔️ DVNTStoreKitManager: Transaction did fail with error '\(transaction.error!.localizedDescription)'" : "💰 ⛔️ DVNTStoreKitManager: Transaction did fail with an unknown error.")
                        self.delegate?.storeKitManagerPurchaseDidFail(productIdentifier: transaction.payment.productIdentifier, error: transaction.error)
                    }
                    queue.finishTransaction(transaction)
                    DispatchQueue.main.async { self.alertManager.hideLoadingView() }
                    return
                default:
                    queue.finishTransaction(transaction)
                    DispatchQueue.main.async { self.alertManager.hideLoadingView() }
                    break
                }
            }
        }
    }
}
