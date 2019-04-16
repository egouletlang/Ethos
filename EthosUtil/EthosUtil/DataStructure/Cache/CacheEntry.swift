//
//  CacheEntry.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

/**
 The CacheEntry class serves as a building block for the various cache classes available in EthosUtil & Beyond. It
 conveniently stores both a `value` (the thing you want to store) and an associated `cost` to the system. The `cost`
 component is optional and **defaults to zero**; the idea was to provide a compute efficient way of determining how
 "big" the cached resources.
 
 `K` can be any type you want but picking a type conforms to NSCoding is useful because most caches support some sort
 of offline mode which allows you to persist your cached data across app sessions.
 
 - TODO: Make CacheEntry only conform to NSCoding when K does as well.
 */
open class CacheEntry<K>: NSObject, NSCoding {
    
    // MARK: - Builders & Constructors
    public init(value: K) {
        self.value = value
        self.cost = 0
    }
    
    public init(value: K, cost: Int) {
        self.value = value
        self.cost = cost
    }
    
    // MARK: - State variables
    /**
     This member stores the data value for this cache entry
     */
    open var value: K
    
    /**
     This member stores the cost associated with this cache entry
     */
    open var cost: Int
    
    // MARK: - NSCoding Delegate Methods
    public required init(coder aDecoder: NSCoder) {
        cost = aDecoder.decodeInteger(forKey: "cost")
        value = aDecoder.decodeObject(forKey: "value") as! K
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(cost, forKey: "cost")
        aCoder.encode(value, forKey: "value")
    }

}
