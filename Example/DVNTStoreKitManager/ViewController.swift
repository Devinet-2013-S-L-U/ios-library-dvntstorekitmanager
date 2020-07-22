//
//  ViewController.swift
//  DVNTStoreKitManager
//
//  Created by raul.vidal@devinet.es on 06/23/2020.
//  Copyright (c) 2020 raul.vidal@devinet.es. All rights reserved.
//

import UIKit
import DVNTStoreKitManager
import SwiftyReceiptValidator

class ViewController: UIViewController
{
    private final let storeKitManager = DVNTStoreKitManager.shared
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.storeKitManager.delegate = self
    }
    
    // MARK: - IBActions
    
    @IBAction func restoreButtonAction(_ sender: Any)
    {
        self.storeKitManager.restore()
    }
}

// MARK: - UITableView extension

extension ViewController: UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.storeKitManager.getProducts().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let currentProduct = self.storeKitManager.getProducts()[indexPath.row]
        
        cell.textLabel?.text = currentProduct.localizedTitle
        
        if let isPurchased = self.storeKitManager.checkIsPurchased(productId: currentProduct.productIdentifier, isNonConsumable: false) {
            if isPurchased {
                cell.detailTextLabel?.text = "purchased"
                cell.detailTextLabel?.textColor = .green
            }else{
                cell.detailTextLabel?.textColor = .lightGray
                cell.detailTextLabel?.text = currentProduct.localizedPrice
            }
        }else{
            cell.detailTextLabel?.text = nil
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let currentProduct = self.storeKitManager.getProducts()[indexPath.row]
        self.storeKitManager.buy(currentProduct)
    }
}

// MARK: - StoreKitManager extension

extension ViewController: DVNTStoreKitManagerDelegate
{
    func storeKitManagerStorePurchaseWasRetained(productIdentifier: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            self.storeKitManager.processStoredPayments()
        })
    }
    
    func storeKitManagerSubscriptionValidationDidFinish()
    {
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
    
    func storeKitManagerActiveSubscriptionDetected(productIdentifier: String, receipt: SRVReceiptInApp)
    {
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
    
    func storeKitManagerPurchaseRestoredSuccesfully(productIdentifier: String, transactionIdentifier: String?)
    {
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
    
    func storeKitManagerPurchaseDidSucced(productIdentifier: String, transactionIdentifier: String?)
    {
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
    
    func storeKitManagerPurchaseDidFail(productIdentifier: String, error: Error?)
    { }
    
    func storekitManagerPurchaseUserUnableToMakePayments()
    { }
    
    func storeKitManagerProductsListDidChange(storeKitManager: DVNTStoreKitManager)
    { }
    
    func storeKitManagerPurchaseCancel()
    { }
}
