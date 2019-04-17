//
//  JSON_EXT.swift
//  EthosNetwork
//
//  Created by Etienne Goulet-Lang on 4/17/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import SwiftyJSON

public extension JSON {
    
    var empty: Bool {
        if (self == JSON.null) {
            return true
        }
        
        if let dict = self.dictionary, dict.keys.count == 0 {
            return true
        }
        
        if let arr = self.array, arr.count == 0 {
            return true
        }
        return false
    }
  
    func removeEmptyKeys() -> JSON {
        if let arr = self.array {
            return JSON(arr.compactMap({ $0.removeEmptyKeys() }).filter({ !$0.empty }))
        }
        
        if let dict = self.dictionary, let rawDict = self.dictionaryObject {
            var newDict = rawDict
            for (key, value) in dict {
                if value == JSON.null {
                    newDict.removeValue(forKey: key)
                } else if value.dictionary != nil {
                    newDict[key] = value.removeEmptyKeys()
                } else if value.array != nil {
                    let clean = value.removeEmptyKeys()
                    if clean.count > 0 {
                        newDict[key] = clean
                    } else {
                        newDict.removeValue(forKey: key)
                    }
                }
            }
            return JSON(newDict)
        }
        return self
        
    }
    
}
