//
//  SKProductExtension.swift
//  DVNTStoreKitManager
//
//  Created by Raúl Vidal Muiños on 26/06/2020.
//

import StoreKit

extension SKProduct
{
    public final var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price) ?? "-"
    }
}
