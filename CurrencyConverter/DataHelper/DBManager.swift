//
//  DBManager.swift
//  CurrencyConverter
//
//  Created by Paresh Thakor on 11/01/21.
//

import Foundation
import RealmSwift
import Alamofire
import SwiftyJSON

/**
    Realm DB healper class which uses `APIManager` and updates `CurrencyPedia` model.
 */
class DBManager {
    static var realmConfiguration: Realm.Configuration {
        
        return  Realm.Configuration(schemaVersion: 2,
                                    migrationBlock:
            { (migration, oldSchemaVersion) in
                
                switch oldSchemaVersion {
                case 1: break
                default: break
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        })
        
    }
    
    static var realm: Realm {
        return try! Realm(configuration: realmConfiguration)
    }
    
    /**
     Fetch Currency rates API call.
     
     - Parameters:
        - completion: callback to be executed once fetch currency rate api call gets completed. It accepts json and error as parameters.
     
     Once the API call gets executed, we will get JSON response in callback and save currency rates against particular currency into DB. If there is any error, the same will be passed in callback.
     
     We would require separate calls to fetch list of currencies and currency rates and then merging response from both API calls into signle Table.
     */
    static func reloadExchangeRate(completion: @escaping (_ quote: CurrencyPedia?, _ error: NSError?) -> Void) {
        
        if let firstQuote = DBManager.realm.objects(CurrencyPedia.self).first {
            APIManager.fetchRateForUSD { (json, error) in
                if let json = json, error == nil {
                    // Update USD Rate
                    guard let source = json["source"].string else {
                        print("Source Invalid..!")
                        
                        completion(firstQuote, NSError(domain: "CCParthError", code: -100, userInfo: ["message": "Invalid Source from API Response."]))
                        return
                    }
                    
                    if let list = json["quotes"].dictionaryObject {
                        
                        try! DBManager.realm.write {
                            
                            // Extract USD Rate only which needs to be updated into Currency list
                            let allCurrencies = firstQuote.currencies
                            for currency in allCurrencies {
                                let rate = list[source + currency.code] as? Double
                                currency.usdRate = rate ?? 0.0
                            }
                            
                            firstQuote.updatedTimeStamp = Date()
                            firstQuote.currencies = allCurrencies
                            
                            DBManager.realm.add(firstQuote, update: .modified)
                        }
                        
                        completion(firstQuote, nil)
                    }
                } else {
                    completion(firstQuote, error)
                }
            }
        }
    }
    
    /**
     Fetch Currency list API call.
     
     - Parameters:
        - completion: callback to be executed once fetch currency list api call gets completed. It accepts json and error as parameters.
     
      Before making any API call, threshold is being checked against `updatedTimeStamp` in `CurrencyPedia`. If call is made withing threshold time limit, simply, local listing would be returned, else actual API call would be performed.
     
      Once the API call gets executed, we will get JSON response in callback and save currency list into DB. If there is any error, the same will be passed in callback.
     
      We would require separate calls to fetch list of currencies and currency rates and then merging response from both API calls into signle Table.
     */
    static func reloadExchangeData(completion: @escaping (_ quote: CurrencyPedia?, _ error: NSError?) -> Void) {
        
        // Fetch premitive record - initially this would be nil
        let dataList = DBManager.realm.objects(CurrencyPedia.self)
        
        // Fetch Data and update Exchange Rates only post 30mins of Data Updates
        let updateStamp = dataList.first?.updatedTimeStamp ?? Date().addingTimeInterval(-(CurrencyLayer_API_THRESHOLD + 60.0))
        
        if updateStamp.compare(Date().addingTimeInterval(-CurrencyLayer_API_THRESHOLD)) == .orderedAscending {
            
            APIManager.fetchCurrencies { (json, error) in
                if let json = json, error == nil {      // When latest JSON data is fetched
                    let db = CurrencyPedia(json)
                    
                    if let first = dataList.first {
                        // Confirm to update id so we can update JSON records on same CurrencyPedia object - First Object only
                        db.id = first.id
                    }
                    
                    try! DBManager.realm.write {
                        print("REALM Start Add ****")
                        DBManager.realm.add(db, update: .modified)
                    }
                    
                    // Reload quote with Rate Data
                    DBManager.reloadExchangeRate { (quote, error) in
                        completion(quote, error)
                    }
                } else {
                    // Fetch data from Realm DB
                    completion(dataList.first, error)
                }
            }
        } else {
            print(">>>>> Exchange Rates updated recently => No need to update too soon..!")
            completion(dataList.first, nil)
        }
        
    }
}
