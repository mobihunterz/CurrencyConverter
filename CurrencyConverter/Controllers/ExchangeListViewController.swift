//
//  ExchangeListViewController.swift
//  CurrencyConverter
//
//  Created by Paresh Thakor on 11/01/21.
//

import UIKit

protocol ExchangeListDelegate: NSObjectProtocol {
    func exchangeListCurrencySelected(_ currency: Currency) -> Void
}

class ExchangeListViewController: UIViewController {

    static let CellReuse_ID = "EXCHANGE_CELL"
    static let Storyboard_ID = "ExchangeListController"
    
    /**
     Main record from RealmDB.
     */
    var quote: CurrencyPedia?
    
    /**
     Selected currency from which value requires to be converted into other currencies.
     */
    var selectedCurrency: Currency?
    
    /**
     Index Path for Selected currency from which value requires to be converted into other currencies.
     */
    var selectedIndexPath: IndexPath?
    
    /**
     All currencies list.
     */
    var currencies: [Currency]? {
        get {
            if let currencies = self.quote?.currencies {
                return Array(currencies).sorted { $0.name < $1.name }
            } else {
                return nil
            }
        }
    }
    
    weak var delegate: ExchangeListDelegate?
    
    @IBOutlet weak var tableview: UITableView! {
        didSet {
            self.tableview.delegate = self
            self.tableview.dataSource = self
            
            self.tableview.register(UITableViewCell.self, forCellReuseIdentifier: ExchangeListViewController.CellReuse_ID)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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


extension ExchangeListViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currencies?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ExchangeListViewController.CellReuse_ID)
        
        if let currency = self.currencies?[indexPath.row] {
            cell?.textLabel?.text = currency.name
            
            // Check if currency is already selected or not and denote with mark
            if let sCurrency = self.selectedCurrency, sCurrency.code == currency.code {
                self.selectedIndexPath = indexPath
                cell?.accessoryType = .checkmark
            } else {
                cell?.accessoryType = .none
            }
        }
        
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableview.deselectRow(at: indexPath, animated: true)
        
        // Un-select and unmark the currency if there is any currency selected before
        if let sIndexPath = self.selectedIndexPath {
            let cell = tableview.cellForRow(at: sIndexPath)
            cell?.accessoryType = .none
        }
        
        // Select new currency and mark it
        if let currency = self.currencies?[indexPath.row] {
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = .checkmark
            
            self.selectedIndexPath = indexPath
            self.selectedCurrency = currency
            
            if let del = self.delegate {
                del.exchangeListCurrencySelected(currency)
            }
        }
    }
}
