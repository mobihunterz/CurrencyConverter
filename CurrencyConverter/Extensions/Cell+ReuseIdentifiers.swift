//
//  Cell+Identifiers.swift
//  CurrencyConverter
//
//  Created by Paresh Thakor on 11/01/21.
//

import UIKit

extension UITableViewCell {
    static var reuseIdentifierCell: String {
        return String(describing: classForCoder())
    }
}

extension UICollectionReusableView {
    static var reuseIdentifierCell: String {
        return String(describing: classForCoder())
    }
}
