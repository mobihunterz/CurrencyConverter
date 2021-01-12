//
//  ConversionTableCell.swift
//  CurrencyConverter
//
//  Created by Paresh Thakor on 11/01/21.
//

import UIKit

protocol ConversionTableCellDelegate: NSObjectProtocol {
    /**
     Update mark for the currency.
     
     - Parameters:
        - currency: Currency which is marked or unmarked.
        - isMarked: If currency is already marked then `isMArked` would be `true` else `false`. When `isMarked == true`, currency is being processed for unmark else process for mark.
     */
    func processCurrencyMark(_ currency: Currency?, alreadyMarked isMarked: Bool)
}

class ConversionTableCell: UITableViewCell {

    @IBOutlet weak var valueLabel: UILabel! {
        didSet {
            self.valueLabel.font = UIFont.strong(font: .verdana, size: 16.0)
        }
    }
    @IBOutlet weak var detailsLabel: UILabel! {
        didSet {
            self.detailsLabel.font = UIFont.strong(font: .verdana, size: 14.0)
        }
    }
    
    @IBOutlet weak var markButton: UIButton!
    
    /**
     The currency from which conversion should be performed. It would be used to calculate conversion value for the `currency`.
     */
    var sourceCurrency: Currency?
    
    /**
     The currency which is being displayed and shows converted value using `sourceCurrency`.
     */
    var currency: Currency?
    
    /**
     The value to be converted from `sourceCurrency` to `currency`.
     */
    var originalValue: Double = 0.0
    
    weak var delegate: ConversionTableCellDelegate?
    
    private var isMarkedCurrency: Bool {
        get {
            // Check if currency is already marked or not into selected Currencies list
            return ((self.selectedCurrencies?.contains(where: { ($0.code == (self.currency?.code ?? "" )) })) ?? false)
        }
    }
    
    /**
     List of already selected currencies.
     */
    var selectedCurrencies: [Currency]? {
        didSet {
            if self.isMarkedCurrency {
                markButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            } else {
                markButton.setImage(UIImage(systemName: "star"), for: .normal)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        markButton.setImage(UIImage(systemName: "star"), for: .normal)
    }
    
    /**
     Shows the currency details by calculating `originalValue` from `sourceCurrency` to `currency`.
     */
    func display(price originalValue: Double = 0.0, for currency: Currency?, from sourceCurrency: Currency?) {
        
        self.currency = currency
        self.sourceCurrency = sourceCurrency
        self.originalValue = originalValue
        
        if let currency = self.currency {
            let rate = currency.usdRate / (self.sourceCurrency?.usdRate ?? 1.0)
            
            let stringValue = String(format: "%.2f", self.originalValue * rate)
            let displayText = stringValue + " " + currency.code
            
            let attributedString = NSMutableAttributedString(string: displayText, attributes: [NSAttributedString.Key.font: UIFont.strong(font: .verdana, size: 16.0)])
            
            let stringValueRange = (displayText as NSString).range(of: stringValue)
            attributedString.addAttribute(.font, value: UIFont.strong(font: .verdanaBold, size: 16.0), range: stringValueRange)
            
            self.valueLabel?.attributedText = attributedString
            self.detailsLabel?.text = currency.name
        }
    }
    
    @IBAction func markCurrencyTapped(_ sender: UIButton) {
        if let del = self.delegate {
            del.processCurrencyMark(self.currency, alreadyMarked: self.isMarkedCurrency)
        }
    }
}
