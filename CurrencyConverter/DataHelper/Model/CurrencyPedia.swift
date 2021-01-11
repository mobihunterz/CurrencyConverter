//
//  CurrencyPedia.swift
//  CurrencyConverter
//
//  Created by Paresh Thakor on 11/01/21.
//

import Foundation
import RealmSwift
import SwiftyJSON

class Currency: Object, Arrayable {
    
    @objc dynamic var code: String!
    @objc dynamic var name: String = ""
    @objc dynamic var usdRate: Double = 0.0
    
    var quote = LinkingObjects(fromType: CurrencyPedia.self, property: "currencies")
    
    required convenience init(_ json: JSON) {
        self.init()
        
        print("test")
    }
    
    override static func primaryKey() -> String? {
        return "code"
    }
    
    
    func conversionValue(_ fromValue: Double = 1.0, _ sourceType: String? = "USD") -> Double {
        return fromValue * usdRate
    }
}


class CurrencyPedia: Object {
    
    @objc dynamic var id = 0
    
    var currencies = List<Currency>()
    @objc dynamic var updatedTimeStamp: Date = Date()
    
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
    
    func clearList() {
        DBManager.realm.delete(DBManager.realm.objects(Currency.self))
        DBManager.realm.delete(DBManager.realm.objects(CurrencyPedia.self))
    }
    
}
