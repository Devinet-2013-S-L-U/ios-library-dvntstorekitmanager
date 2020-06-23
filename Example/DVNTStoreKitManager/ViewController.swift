//
//  ViewController.swift
//  DVNTStoreKitManager
//
//  Created by raul.vidal@devinet.es on 06/23/2020.
//  Copyright (c) 2020 raul.vidal@devinet.es. All rights reserved.
//

import UIKit
import DVNTStoreKitManager

class ViewController: UIViewController
{
    private final let storeKitManager = DVNTStoreKitManager.shared
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.storeKitManager.delegate = self
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
        cell.detailTextLabel?.text = self.storeKitManager.getLocalizedPrice(currentProduct)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let currentProduct = self.storeKitManager.getProducts()[indexPath.row]
        self.storeKitManager.purchaseProduct(currentProduct)
    }
}

// MARK: - StoreKitManager extension

extension ViewController: DVNTStoreKitManagerDelegate
{
    func storeKitManagerPurchaseDidFail(error: Error?)
    {
        print("Purchase did fail")
    }
    
    func storekitManagerPurchaseUserUnableToMakePayments()
    {
        print("User is unable to make payments")
    }
    
    func storeKitManagerProductsListDidChange(storeKitManager: DVNTStoreKitManager)
    {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
