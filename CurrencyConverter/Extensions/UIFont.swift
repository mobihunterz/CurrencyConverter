//
//  UIFont.swift
//  CurrencyConverter
//
//  Created by Paresh Thakor on 11/01/21.
//

import UIKit

extension UIFont {
    
    static func strong(font: CCParthFont, size: CGFloat) -> UIFont {
        return UIFont(name: font.rawValue, size: size)!
    }
    
}
