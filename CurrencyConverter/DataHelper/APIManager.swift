//
//  APIManager.swift
//  CurrencyConverter
//
//  Created by Paresh Thakor on 11/01/21.
//

import Foundation
import Alamofire
import SwiftyJSON

enum Router: URLConvertible {
    
    func asURL() throws -> URL {
        var urlString: String
        switch self {
        case .rateForUSD:
            urlString = "http://api.currencylayer.com/live"
        case .currencyList:
            urlString = "http://api.currencylayer.com/list"
        }
        
        if let url = URL(string: urlString) {
            return url
        } else {
            throw AFError.invalidURL(url: self)
        }
    }
    
    case rateForUSD
    case currencyList
}

struct APIKey {
    static let Success      = "success"
    static let Data         = "data"
    static let Errors       = "errors"
    
    static let Info         = "info"
}

/**
 
 The APIManager class makes HTTP requests to the backend server using `Alamofire`.
 
 */
class APIManager {
    
    /**
     Fetch Currencies API call.
     
     - Parameters:
        - completion: callback to be executed once fetch currencies api call gets completed. It accepts json and error as parameters.
     
     Once the API call gets executed, we will get JSON response in callback and save currency list into DB. If there is any error, the same will be passed in callback.
     
     We would require separate calls to fetch list of currencies and currency rates and then merging response from both API calls into signle Table.
     */
    static func fetchCurrencies(completion: @escaping (_ json: JSON?, _ error: NSError?) -> Void) {
        request(.get) { json, error in
            completion(json, error)
        }
    }
    
    /**
     Fetch Currency rates API call.
     
     - Parameters:
        - completion: callback to be executed once fetch currency rate api call gets completed. It accepts json and error as parameters.
     
     Once the API call gets executed, we will get JSON response in callback and save currency rates against particular currency into DB. If there is any error, the same will be passed in callback.
     
     We would require separate calls to fetch list of currencies and currency rates and then merging response from both API calls into signle Table.
     */
    static func fetchRateForUSD(completion: @escaping (_ json: JSON?, _ error: NSError?) -> Void) {
        request(.get, router: .rateForUSD) { json, error in
            completion(json, error)
        }

    }
    
    /**
     Creates alamofire request and reads JSON response.
     
     If any error in response, error with Response = nil will be returned.
     If response is ok, JSON response object with error = nil will be returned.
     
     `access_key` is required by each API call, so, adding `access_key` inside request call would make code handy.
     */
    fileprivate static func request(_ method: Alamofire.HTTPMethod, router: Router = .currencyList, headers: [String : String]? = nil, encoding: ParameterEncoding = JSONEncoding.default, completion: @escaping (_ json: JSON?, _ error: NSError?) -> Void) {
        
        AF.request(router, method: method, parameters: ["access_key": CurrencyLayer_Access_Token], headers: ["Accept": "application/json"], interceptor: nil, requestModifier: nil).responseJSON(completionHandler: { response in
            
            print(response)
            
            if let error = response.error {
                print()
                print("ERROR: \(error.localizedDescription)")
                print()
                completion(nil, error as NSError)
                return
            }
            
            if let json = try? JSON(data: response.data!) {
                print()
                print("RESPONSE:")
                print()
                print(json)
                
                if let error = json["error"].string {
                    let error = NSError(domain: "CCParthErrorDomain", code: -1, userInfo: [kCFErrorLocalizedDescriptionKey! as String : error])
                    completion(nil, error)
                    return
                }
                
                completion(json, nil)
            } else {
                print("Error parsing JSON ====> \(response)")
                completion(JSON(stringLiteral: response.description), nil)
            }
            
        })
    }
    
}
