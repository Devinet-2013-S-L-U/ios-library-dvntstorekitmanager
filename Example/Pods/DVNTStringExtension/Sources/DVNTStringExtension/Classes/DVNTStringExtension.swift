//
//  DVNTStringExtension.swift
//
//
//  Created by Raúl Vidal Muiños on 4/6/18.
//  Copyright © 2019 Devinet 2013, S.L.U. All rights reserved.
//

import UIKit

extension String
{
    public static func localize(_ key: String, comment: String) -> String
    {
        return NSLocalizedString(key, comment: comment)
    }
    
    public static func localize(_ key: String) -> String
    {
        return self.localize(key, comment: "")
    }
    
    public static func localize(_ key: String, fromClass aClass: AnyClass, forResource resource: String, ofType type: String) -> String
    {
        let path = Bundle(for: aClass).path(forResource: resource, ofType: type)!
        let bundle = Bundle(path: path) ?? Bundle.main
        return NSLocalizedString(key, bundle: bundle, comment: "")
    }
    
    public func removingWhitespaces() -> String
    {
        return components(separatedBy: .whitespaces).joined()
    }
}
