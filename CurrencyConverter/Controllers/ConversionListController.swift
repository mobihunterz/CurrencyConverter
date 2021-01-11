//
//  ConversionListController.swift
//  CurrencyConverter
//
//  Created by Paresh Thakor on 11/01/21.
//

import UIKit

class ConversionListController: UIViewController {

    static let CellReuse_ID = "CONVERSION_CELL"
    static let Storyboard_ID = "ConversionListController"
    
    var originalValue: Double = 0.0
    var sourceCurrency: Currency?
    var selectedCurrencies: [Currency]? {
        didSet {
            self.tableview.reloadData()
        }
    }
    
    var quote: CurrencyPedia?
    
    var currencies: [Currency]? {
        get {
            if let currencies = self.quote?.currencies {
                return Array(currencies).sorted { $0.name < $1.name }
            } else {
                return nil
            }
        }
    }
    
    @IBOutlet weak var tableview: UITableView! {
        didSet {
            self.tableview.delegate = self
            self.tableview.dataSource = self
            
            self.tableview.register(ConversionTableCell.nib, forCellReuseIdentifier: ConversionTableCell.reuseIdentifierCell)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshList(self.originalValue, self.sourceCurrency)
    }
    
    func refreshList(_ sourceValue: Double, _ sourceCurrency: Currency?) {
        self.originalValue = sourceValue
        self.sourceCurrency = sourceCurrency
        
        self.tableview.reloadData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ConversionListController:UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (self.selectedCurrencies?.count ?? 0) > 0 {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "To"
        } else {
            return "And others..."
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ((self.selectedCurrencies?.count ?? 0) > 0) && (section == 0) {
            return self.selectedCurrencies?.count ?? 0
        } else {
            return self.currencies?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversionTableCell.reuseIdentifierCell, for: indexPath) as! ConversionTableCell
        
        var theCurrency: Currency?
        
        if ((self.selectedCurrencies?.count ?? 0) > 0) && (indexPath.section == 0) {
            theCurrency = self.selectedCurrencies?[indexPath.row]
        } else {
            theCurrency = self.currencies?[indexPath.row]
        }
        
        cell.delegate = self
        cell.display(price: self.originalValue, for: theCurrency, from: self.sourceCurrency)
        cell.selectedCurrencies = self.selectedCurrencies
        
        return cell
    }
}

extension ConversionListController: ConversionTableCellDelegate {
    func processCurrencyMark(_ currency: Currency?, alreadyMarked isMarked: Bool) {
        
        if let currency = currency {
            var selection = self.selectedCurrencies ?? [Currency]()
            
            // If currency is marked then definitely need to un-mark it
            // If currency is filtered then its already selected and marked
            if isMarked,
               selection.filter( {   $0.code == currency.code    }).count > 0 {
                    selection.removeAll {   $0.code == currency.code    }
            } else {
                
                // Just add currency if not already marked (i.e. added)
                selection.append(currency)
            }
            
            self.selectedCurrencies = selection
        }
    }
}
