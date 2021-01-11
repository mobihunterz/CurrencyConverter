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
    
    static func reloadExchangeRate(completion: @escaping (_ quote: CurrencyPedia?, _ error: NSError?) -> Void) {
        
        if let firstQuote = DBManager.realm.objects(CurrencyPedia.self).first {
            APIManager.fetchRateForUSD { (json, error) in
                if let json = json, error == nil {
                    // Update USD Rate
                    guard let source = json["source"].string else {
                        print("Source Invalid..!")
                        
                        // TODO: Some error would be there
                        completion(firstQuote, nil)
                        return
                    }
                    
                    if let list = json["quotes"].dictionaryObject {
                        
                        try! DBManager.realm.write {
                            
                            let allCurrencies = firstQuote.currencies
                            for currency in allCurrencies {
                                let rate = list[source + currency.code] as? Double
                                currency.usdRate = rate ?? 0.0
                            }
                            
                            //let time = json["timestamp"].doubleValue
                            //firstQuote.updatedTimeStamp = Date(timeIntervalSince1970: time)
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
    
    static func reloadExchangeData(completion: @escaping (_ quote: CurrencyPedia?, _ error: NSError?) -> Void) {
        
        let dataList = DBManager.realm.objects(CurrencyPedia.self)
        
        // Fetch Data and update Exchange Rates only post 30mins of Data Updates
        let updateStamp = dataList.first?.updatedTimeStamp ?? Date().addingTimeInterval(-60*31)
        if updateStamp.compare(Date().addingTimeInterval(-60*30)) == .orderedAscending {
            APIManager.fetchCurrencies { (json, error) in
                
                if let json = json, error == nil {
                    let db = CurrencyPedia(json)
                    
                    if let first = dataList.first {
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
