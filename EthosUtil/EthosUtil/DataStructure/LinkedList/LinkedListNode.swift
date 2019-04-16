//
//  LinkedListNode.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

/**
 The LinkedListNode class serves as a building block for the various linked list data structures available in this
 project. It has a reference to both the previous and next node in the chain
 
 `T` can be any type you want but picking a type conforms to NSCoding is useful because most caches support some sort
 of offline mode which allows you to persist your cached data across app sessions.
 
 - TODO: Make CacheEntry only conform to NSCoding when K does as well.
 */
open class LinkedListNode<T: Equatable & Comparable> : NSCoding {
    
    init(value: T) {
        self.value = value
    }
    
    /**
     This parameter stores the data value for this linked list node
     */
    var value: T
    
    /**
     This parameter stores a reference to previous node in the linked list, if it exists
     */
    var prev: LinkedListNode<T>?
    
    /**
     This parameter stores a reference to next node in the linked list, if it exists
     */
    var next: LinkedListNode<T>?
    
    // MARK: - NSCoding Delegate Methods
    public required init(coder aDecoder: NSCoder) {
        value = aDecoder.decodeObject(forKey: "value") as! T
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(value, forKey: "value")
    }
    
    
}
