//
//  ViewControllerTests.swift
//  CurrencyConverterTests
//
//  Created by Paresh Thakor on 12/01/21.
//

import XCTest
@testable import CurrencyConverter

class ViewControllerTests: XCTestCase {

    var sut: ViewController!

    override func setUp() {
        super.setUp()
        sut = self.getController()
        
        sut.loadViewIfNeeded()
    }

    override func tearDown() {
      sut = nil
      super.tearDown()
    }
    
    override func setUpWithError() throws {
        //sut.loadViewIfNeeded()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    fileprivate func getController() -> ViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: ViewController.Storyboard_ID) as! ViewController
    }

    // Asynchronous test
    func testFetchCurrenciesSuccess() {
      
      let promise = expectation(description: "Success: true")
        var theError: NSError?
        
        APIManager.fetchCurrencies { (json, error) in
            if let error = error {
                //XCTFail("Error: \(error.localizedDescription)")
                theError = error
            } else if let success = json?["success"].boolValue, success {
                promise.fulfill()
                return
            } else if let error = json?["error"].dictionary, let info = error["info"]?.stringValue {
                //XCTFail("Request failed with info: \(info)")
                theError = NSError(domain: "CCParthError", code: error["code"]?.intValue ?? -100, userInfo: ["info": info])
            } else {
                //XCTFail("Request failed with unknown error")
                theError = NSError(domain: "CCParthError", code: -100, userInfo: ["info": "Unknown error"])
            }
            
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 15)
        
        XCTAssertNil(theError, theError?.localizedDescription ?? "Unknown Error")
    }
    
    func testValueFieldControlsConnectedWhenLoaded() throws {
        _ = try XCTUnwrap(sut.valueField, "The VALUE UITextField is not connected")
        _ = try XCTUnwrap(sut.exchangeButton, "The Exchange UIButton is not connected")
    }
    
    func testValueField_HasDigitsContentTypeSet() throws {
        let valueField = try XCTUnwrap(sut.valueField, "The VALUE UITextField is not connected")
        
        XCTAssertEqual(valueField.keyboardType, .decimalPad, "VALUE UITextField does not have a Decimal keypad set.")
    }
}


class APIManagerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // Asynchronous test: success fast, failure slow
    func testFetchCurrenciesSuccess() {
      
      let promise = expectation(description: "Success: true")
        var theError: NSError?
        
        APIManager.fetchCurrencies { (json, error) in
            if let error = error {
                //XCTFail("Error: \(error.localizedDescription)")
                theError = error
            } else if let success = json?["success"].boolValue, success {
                promise.fulfill()
                return
            } else if let error = json?["error"].dictionary, let info = error["info"]?.stringValue {
                //XCTFail("Request failed with info: \(info)")
                theError = NSError(domain: "CCParthError", code: error["code"]?.intValue ?? -100, userInfo: ["info": info])
            } else {
                //XCTFail("Request failed with unknown error")
                theError = NSError(domain: "CCParthError", code: -100, userInfo: ["info": "Unknown error"])
            }
            
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 15)
        
        XCTAssertNil(theError, theError?.localizedDescription ?? "Unknown Error")
    }
}
