//
//  Dictionary+Stringify.swift
//
//  Created by Daniel Dean on 12/13/16.
//

import Foundation

extension Dictionary {
    
    /**
     Converts a Dictionary into a string of key=value pairs separated by 
     ampersands.  
     
     - param urlEncode: When set to true, the value of each key/value pair in 
                        the dictionary will be urlencoded.
     
     - returns: A url parameter string
     */    public func stringifyAsURLParams(_ urlEncode: Bool) -> String {
        var query = String()
        var firstItem = true;
        for (key, value) in self {
            if (!(key is String) || !(value is String)) {
                continue
            }
            var encoded:String? = value as? String
            if (urlEncode) {
                encoded = encoded?.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)
            }
            if (!firstItem) {
                query += "&"
            } else {
                firstItem = false
            }
            query += (key as! String) + "=" + encoded!
        }
        return query as String
    }
}
