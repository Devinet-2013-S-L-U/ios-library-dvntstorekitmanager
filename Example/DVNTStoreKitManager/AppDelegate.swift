//
//  AppDelegate.swift
//  DVNTStoreKitManager
//
//  Created by raul.vidal@devinet.es on 06/23/2020.
//  Copyright (c) 2020 raul.vidal@devinet.es. All rights reserved.
//

import UIKit
import DVNTStoreKitManager

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    private final let storeKitManager = DVNTStoreKitManager.shared
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        self.initializeStoreKitManager()
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication)
    {
        self.storeKitManager.setShouldAddStorePayment(false)
    }
    
    // MARK: - Other methods
    
    private final func initializeStoreKitManager()
    {
        self.storeKitManager.setSecret(Constants.InAppPurchase.SECRET)
        self.storeKitManager.setInAppPurchaseIdentifiers(Constants.InAppPurchase.ITEM_IDENTIFIERS)
        self.storeKitManager.setSpinnerAppearance(baseColor: .white, inkColor: .darkText, backgroundColor: .black)
    }
}
