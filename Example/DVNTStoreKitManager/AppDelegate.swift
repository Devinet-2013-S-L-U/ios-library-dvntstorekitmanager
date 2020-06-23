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
        self.storeKitManager.setInAppPurchaseIdentifiers(Constants.InAppPurchase.ITEM_IDENTIFIERS)
        return true
    }
}
