//
//  DVNTAlertManager.swift
//
//
//  Created by Raúl Vidal Muiños on 7/4/19.
//  Copyright © 2019 Devinet 2013, S.L.U. All rights reserved.
//

import UIKit
import DVNTStringExtension
import DVNTUIWindowExtension

public enum AlertStyleType
{
    case iOS
}

public class DVNTAlertManager
{
    public static let shared = DVNTAlertManager()
    
    fileprivate var loadingView: UIView?
    fileprivate var inkColor: UIColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    fileprivate var baseColor: UIColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    fileprivate var alertStyle: AlertStyleType = .iOS
    fileprivate var isShowingLoadingView: Bool = false
    fileprivate var loadingViewBackgroundColor: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.7)
    
    private init()
    { }
    
    // MARK: - Setters
    
    public func setAlertStyle(_ style: AlertStyleType)
    {
        self.alertStyle = style
        self.loadingView = nil
    }
    
    public func setBaseColor(_ color: UIColor)
    {
        self.baseColor = color
        
        if let loadingView = self.loadingView {
            switch self.alertStyle {
            case .iOS:
                for view in loadingView.subviews {
                    if view is UIActivityIndicatorView {
                        let activityIndicator = view as! UIActivityIndicatorView
                        activityIndicator.color = color
                        break
                    }
                }
            }
        }
    }
    
    public func setInkColor(_ color: UIColor)
    {
        self.inkColor = color
    }
    
    public func setLoadingViewBackgroundColor(_ color: UIColor)
    {
        self.loadingViewBackgroundColor = color
        
        if let loadingView = self.loadingView {
            loadingView.backgroundColor = color
        }
    }
    
    // MARK: - Show alert methods
    
    public func showLoadingView(isUserinteractionEnabled: Bool)
    {
        if !self.isShowingLoadingView {
            DispatchQueue.main.async {
                if let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
                    keyWindow.getVisibleViewController(completed: {(currentViewController) -> Void in
                        if let currentViewController = currentViewController {
                            if self.loadingView == nil {
                                let currentViewframe = currentViewController.view.bounds
                                self.loadingView = UIView(frame: CGRect(x: ((currentViewframe.width / 2) - (50 / 2)), y: ((currentViewframe.height / 2) - (50 / 2)), width: 50.0, height: 50.0))
                                if let loadingView = self.loadingView {
                                    loadingView.backgroundColor = self.loadingViewBackgroundColor
                                    loadingView.layer.cornerRadius = 4
                                }
                            }
                            
                            if let loadingView = self.loadingView {
                                switch self.alertStyle {
                                case .iOS:
                                    var found = false
                                    for view in loadingView.subviews {
                                        if view is UIActivityIndicatorView {
                                            let activityIndicator = view as! UIActivityIndicatorView
                                            activityIndicator.startAnimating()
                                            found = true
                                            break
                                        }
                                    }
                                    if !found {
                                        var activityIndicator: UIActivityIndicatorView!
                                        if #available(iOS 13.0, *) {
                                            activityIndicator = UIActivityIndicatorView(style: .large)
                                        } else {
                                            activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
                                        }
                                        activityIndicator.color = self.baseColor
                                        activityIndicator.frame = CGRect(x: ((loadingView.frame.width / 2) - (activityIndicator.frame.width / 2)), y: ((loadingView.frame.height / 2) - (activityIndicator.frame.height / 2)), width: activityIndicator.frame.width, height: activityIndicator.frame.height)
                                        loadingView.addSubview(activityIndicator)
                                        activityIndicator.startAnimating()
                                    }
                                }
                                
                                self.isShowingLoadingView = true
                                currentViewController.view.addSubview(loadingView)
                                keyWindow.isUserInteractionEnabled = isUserinteractionEnabled
                            }
                        }
                    })
                }
            }
        }
    }
    
    public func hideLoadingView()
    {
        if self.isShowingLoadingView {
            DispatchQueue.main.async {
                if let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }), let loadingView = self.loadingView {
                    switch self.alertStyle {
                    case .iOS:
                        for view in loadingView.subviews {
                            if view is UIActivityIndicatorView {
                                let activityIndicator = view as! UIActivityIndicatorView
                                activityIndicator.stopAnimating()
                                break
                            }
                        }
                    }
                    loadingView.removeFromSuperview()
                    keyWindow.isUserInteractionEnabled = true
                    self.isShowingLoadingView = false
                }
            }
        }
    }
    
    public func showBasicAlert(title: String, message: String)
    {
        DispatchQueue.main.async {
            if let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
                keyWindow.getVisibleViewController(completed: {(currentViewController) -> Void in
                    if let currentViewController = currentViewController {
                        switch self.alertStyle {
                        case .iOS:
                            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                            let buttonText = String.localize("general_ok", fromClass: DVNTAlertManager.self, forResource: "DVNTAlertManagerResources", ofType: "bundle").capitalized
                            alertController.addAction(UIAlertAction(title: buttonText, style: .default))
                            currentViewController.present(alertController, animated: true, completion: nil)
                        }
                    }
                })
            }
        }
    }
    
    public func showBasicAlertWithAction(title: String, message: String, buttonTouched: @escaping (Int) -> Void)
    {
        DispatchQueue.main.async {
            if let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
                keyWindow.getVisibleViewController(completed: {(currentViewController) -> Void in
                    if let currentViewController = currentViewController {
                        switch self.alertStyle {
                        case .iOS:
                            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                            let buttonText = String.localize("general_ok", fromClass: DVNTAlertManager.self, forResource: "DVNTAlertManagerResources", ofType: "bundle").capitalized
                            alertController.addAction(UIAlertAction(title: buttonText, style: .default) { (action) in buttonTouched(0) })
                            currentViewController.present(alertController, animated: true, completion: nil)
                        }
                    }
                })
            }
        }
    }
    
    public func showAlertWithTwoOptions(title: String, message: String, buttonActionText: String, cancelButtonText: String, buttonTouched: @escaping (Int) -> Void)
    {
        DispatchQueue.main.async {
            if let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
                keyWindow.getVisibleViewController(completed: {(currentViewController) -> Void in
                    if let currentViewController = currentViewController {
                        switch self.alertStyle {
                        case .iOS:
                            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: buttonActionText, style: .destructive) { (action) in buttonTouched(0) })
                            alertController.addAction(UIAlertAction(title: cancelButtonText, style: .default) { (action) in buttonTouched(1) })
                            currentViewController.present(alertController, animated: true, completion: nil)
                        }
                    }
                })
            }
        }
    }
    
    public func showAlertWithThreeOptions(title: String, message: String, buttonActionText: String, buttonAction2Text: String, cancelButtonText: String, buttonTouched: @escaping (Int) -> Void)
    {
        DispatchQueue.main.async {
            if let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
                keyWindow.getVisibleViewController(completed: {(currentViewController) -> Void in
                    if let currentViewController = currentViewController {
                        switch self.alertStyle {
                        case .iOS:
                            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: buttonActionText, style: .default) { (action) in buttonTouched(0) })
                            alertController.addAction(UIAlertAction(title: buttonAction2Text, style: .default) { (action) in buttonTouched(1) })
                            alertController.addAction(UIAlertAction(title: cancelButtonText, style: .destructive) { (action) in buttonTouched(2) })
                            currentViewController.present(alertController, animated: true, completion: nil)
                        }
                    }
                })
            }
        }
    }
    
    public func showAlertWithTextField(title: String, message: String, textFieldPlaceholder: String, buttonActionText: String, cancelButtonText: String, buttonTouched: @escaping (Int, String?) -> Void)
    {
        DispatchQueue.main.async {
            if let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
                keyWindow.getVisibleViewController(completed: {(currentViewController) -> Void in
                    if let currentViewController = currentViewController {
                        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                        alertController.addTextField(configurationHandler: { textField in
                            textField.placeholder = textFieldPlaceholder
                        })
                        
                        alertController.addAction(UIAlertAction(title: buttonActionText, style: .default, handler: { action in
                            buttonTouched(0, alertController.textFields?.first?.text)
                        }))
                        alertController.addAction(UIAlertAction(title: cancelButtonText, style: .cancel) { (action) in buttonTouched(1, nil) })
                        currentViewController.present(alertController, animated: true, completion: nil)
                    }
                })
            }
        }
    }
}
