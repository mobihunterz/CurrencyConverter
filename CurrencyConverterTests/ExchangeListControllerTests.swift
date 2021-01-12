//
//  ExchangeListControllerTests.swift
//  CurrencyConverterTests
//
//  Created by Paresh Thakor on 12/01/21.
//

import XCTest
@testable import CurrencyConverter

struct Currency {
    var name: String = ""
    var code: String = ""
    var usdRate: Double = 0.0
}

class CurrenciesDataSource: NSObject, UITableViewDataSource {

    private let currencies: [Currency]
        
    init(currencies: [Currency]) {
        self.currencies = currencies
        super.init()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ExchangeListViewController.CellReuse_ID, for: indexPath)
        cell.textLabel?.text = currencies[indexPath.row].name
        return cell
    }
    
}

class CurrencyDataSourceTests: XCTestCase {

    func test_hasOneSection() {
        let sut = CurrenciesDataSource(currencies: [])
        
        let tablewView = UITableView()
        tablewView.dataSource = sut
        
        let numberOfSections = tablewView.numberOfSections
        
        XCTAssertEqual(1, numberOfSections)
    }
    
    func test_rowsEqualsCurrencyCount() {
        let currencies = [Currency(name: "USD", code: "United States Dollar"),
                          Currency(name: "ASD", code: "Australian Dollar"),
                          Currency(name: "INR", code: "Indian Rupees"),
                          Currency(name: "EUR", code: "Euro"),
                          Currency(name: "BTC", code: "Bitcoin")]
        let sut = CurrenciesDataSource(currencies: currencies)
        
        let tablewView = UITableView()
        tablewView.dataSource = sut
        
        XCTAssertEqual(currencies.count, tablewView.numberOfRows(inSection: 0))
    }
    
    func test_showCurrencyCell() {
        let currencies = [Currency(name: "USD", code: "United States Dollar"),
                          Currency(name: "ASD", code: "Australian Dollar"),
                          Currency(name: "INR", code: "Indian Rupees"),
                          Currency(name: "EUR", code: "Euro"),
                          Currency(name: "BTC", code: "Bitcoin")]
        
        let sut = CurrenciesDataSource(currencies: currencies)
        
        let listController = ExchangeListControllerTests().getListController()
        _ = listController.view
        
        let tablewView = listController.tableview
        tablewView?.dataSource = sut
        tablewView?.reloadData()
        
        var index: Int = 0
        for currency in currencies {
            if let cell = tablewView?.cellForRow(at: IndexPath(row: index, section: 0)) {
                XCTAssertEqual(currency.name, cell.textLabel?.text)
            } else {
                XCTAssert(false, "Cell is not presented here.. :(")
            }
            
            index += 1
        }
    }
}

class ExchangeListControllerTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_setsTableView() {
        let listController = self.getListController()
        _ = listController.view
            
        XCTAssertNotNil(listController.tableview)
    }
    
    fileprivate func getListController() -> ExchangeListViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: ExchangeListViewController.Storyboard_ID) as! ExchangeListViewController
    }

}
