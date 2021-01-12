//
//  Arrayable.swift
//  CurrencyConverter
//
//  Created by Paresh Thakor on 11/01/21.
//

import Foundation
import SwiftyJSON

// Helper method for Realm-model
protocol Arrayable {
    init(_ json: JSON) throws
}

extension JSON  {
    func toArray<E: Arrayable>() -> [E] {
        var res: [E] = [E]()
        if let ar = self.array {
            for i in ar {
                if let new = try? E(i) {
                    res.append(new)
                }
            }
        }
        
        return res
    }
}
