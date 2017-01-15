//
//  NSData+JSON.swift
//
//  Created by Daniel Dean on 12/14/16.
//

import Foundation

extension Data {
    
    /**
     Converts a JSON HTTP response body into a Dictionary
     
     - returns: Dictionary representation of the JSON object
     */
    public func jsonDataAsDictionary() throws -> Dictionary<String, AnyObject>? {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: self, options: JSONSerialization.ReadingOptions.mutableContainers)
            let jsonDict:Dictionary<String, AnyObject>? = jsonObject as? Dictionary
            if (jsonDict == nil) {
                throw NSError(domain: "net.dhdean.jsondata", code: 99, userInfo: nil)
            }
            return jsonDict
        } catch _ {
            return nil
        }
    }

}
