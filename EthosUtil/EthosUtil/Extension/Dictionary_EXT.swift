//
//  Dictionary_EXT.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

public extension Dictionary {
    
    /**
     This method provides a safe access to the dictionary. The method returns the target element if the key exists,
     otherwise it returns the `def` parameter value
     
     - parameters:
         - key: target pair key
         - def: default value if the key is not present. Defaults to `nil`
     
     - returns: the dictionary element or `def` parameter value
     */
    func get(_ key: Key,_ def: Value? = nil) -> Value? {
        if let v = self[key] {
            return v
        }
        return def
    }
    
    /**
     This method gets the current value for a key, if it exists. If the key does not exists, the method uses the
     `callback` parameter to fetch the value for that key.
     
     - parameters:
         - key: target pair key
         - callback: a closure used to fetch the value for the key
     
     - returns: the value for the (key, value) pair
     */
    mutating func get(_ key: Key, callback: () -> Value?) -> Value? {
        if let curr = self.get(key) {
            return curr
        }
        let value = callback()
        return self.set(key, value, allowNil: false)
    }
    
    /**
     This method creates a (key, value) pair in the dictionary and returns the value.
     
     - parameters:
         - key: new key
         - value: new value
     
     - returns: the value for the (key, value) pair
     */
    @discardableResult mutating func set(_ key: Key,_ value: Value?, allowNil: Bool = true) -> Value? {
        if !allowNil && value == nil {
            return value
        }
        self[key] = value
        return value
    }
    
}
