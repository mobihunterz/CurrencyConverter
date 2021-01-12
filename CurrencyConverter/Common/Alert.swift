//
//  Alert.swift
//  CurrencyConverter
//
//  Created by Paresh Thakor on 11/01/21.
//

import UIKit

// Helper Alert methods

func alert(_ message: String) {
    alert(nil, message)
}

func alert(_ message: String, presented: UIViewController?) {
    alert(message, nil, presented: presented)
}

func alert(_ title: String?, _ message: String?) {
    alert(title, message, presented: nil)
}

func alertError(_ message: String) {
    alert(nil, message)
}

func alert(_ title: String?,
           _ message: String?,
           actions: [UIAlertAction]? = nil,
           presented: UIViewController?) {
    
    let alertController = UIAlertController(title: title,
                                            message: message,
                                            preferredStyle: .alert)
    
    if let actions = actions {
        actions.forEach({ alertController.addAction($0) })
    } else {
        alertController.addAction(UIAlertAction(title: "Ok",
                                                style: .default,
                                                handler: nil))
    }
    
    alertController.view.tintColor = UIColor.blue
    if let presented = presented {
        presented.present(alertController, animated: true, completion: nil)
    } else {
        present(alertController, animated: true)
    }
}

func alertHelp(_ text: String, presented: UIViewController?) {
    
    let alertController = UIAlertController(title: nil,
                                            message: text,
                                            preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "Ok",
                                            style: .default,
                                            handler: nil))
    alertController.view.tintColor = UIColor.blue
    
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .left
    
    let messageText = NSMutableAttributedString(
        string: text,
        attributes: [
            .paragraphStyle: paragraphStyle,
            .font : UIFont.systemFont(ofSize: 17),
            .foregroundColor : UIColor.black
        ]
    )
    
    alertController.setValue(messageText, forKey: "attributedMessage")
    
    if let presented = presented {
        presented.present(alertController, animated: true, completion: nil)
    } else {
        present(alertController, animated: true)
    }
}

func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Swift.Void)? = nil) {
    presentedVC()?.present(viewControllerToPresent, animated: flag, completion: completion)
}

// Get the first view controller on screen
func presentedVC() -> UIViewController? {
    let keyWindow = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
    return keyWindow?.rootViewController?.presentedViewController ?? keyWindow?.rootViewController
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
