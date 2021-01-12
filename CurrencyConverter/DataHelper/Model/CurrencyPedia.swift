//
//  CurrencyPedia.swift
//  CurrencyConverter
//
//  Created by Paresh Thakor on 11/01/21.
//

import Foundation
import RealmSwift
import SwiftyJSON

/**
 `Currency` model from Realm.
 
 Storing currency code, name and USD Rate from different APIs.
 */
class Currency: Object, Arrayable {
    
    @objc dynamic var code: String!
    @objc dynamic var name: String = ""
    @objc dynamic var usdRate: Double = 0.0
    
    // Linking back to main CurrencyPrdia Quote
    var quote = LinkingObjects(fromType: CurrencyPedia.self, property: "currencies")
    
    // JSON initializer is unused as values are assigned directly from dictionary objects and individual values are required to be assigned with different API calls
    required convenience init(_ json: JSON) {
        self.init()
    }
    
    override static func primaryKey() -> String? {
        return "code"
    }
}


/**
 `CurrencyPedia` model from Realm which is the main base model for the DB.
 
 Keeps reference to `Currency` listing and `updatedTimeStamp` to measure when rate data is updated.
 */
class CurrencyPedia: Object {
    
    @objc dynamic var id = 0
    var currencies = List<Currency>()
    @objc dynamic var updatedTimeStamp: Date = Date()
    
    /**
     Parses JSON data and stores them into main model - `CurrencyPedia`.
     */
    required convenience init(_ json: JSON) {
        self.init()
        
        self.id = CurrencyPedia.getId()
        self.updatedTimeStamp = Date()
        
        if let list = json["currencies"].dictionaryObject {
            
            for key in list.keys {
                let symbol = key
                let name = list[key] as? String
                
                let c = Currency()
                c.code = symbol
                c.name = name ?? ""
                
                self.currencies.append(c)
            }
        }
        
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    /**
     Returns updated value from DB list.
     Ideally, it would be `total` of `CurrencyPedia` objects + `1`
     */
    class func getId() -> Int {
        let realm = DBManager.realm
        
        let allEntries = realm.objects(CurrencyPedia.self)
        if allEntries.count > 0 {
            let lastId = allEntries.max(ofProperty: "id") as Int?
            return lastId! + 1
        } else {
            return 1
        }
    }
    
    /**
     Removes all data from `Currency` and `CurrencyPedia` tables.
     */
    func clearList() {
        DBManager.realm.delete(DBManager.realm.objects(Currency.self))
        DBManager.realm.delete(DBManager.realm.objects(CurrencyPedia.self))
    }
    
}
