//
//  Cell+Identifiers.swift
//  CurrencyConverter
//
//  Created by Paresh Thakor on 11/01/21.
//

import UIKit

/// Reusable identifier properties for UITableViewCell
extension UITableViewCell {
    static var reuseIdentifierCell: String {
        return String(describing: classForCoder())
    }
}

/// Reusable identifier properties for UICollectionViewCell
extension UICollectionReusableView {
    static var reuseIdentifierCell: String {
        return String(describing: classForCoder())
    }
}
