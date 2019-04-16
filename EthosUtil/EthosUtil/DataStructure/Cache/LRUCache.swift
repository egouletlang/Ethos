//
//  LRUCache.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

/**
 The LRUCache class leverages a Least Recently Used algorithm to optimize its caching solution. The data strucutre
 first sets a maxmium cost threshhold and then tracks the cost associate with a each CacheEntry. When the total cost of
 the data collection exceeds the maximum cost threshhold, the data structure will evict the oldest records first.
 
 The maxmium cost threshhold defaults to 100MB
 
 By default, this cache is not thread safe. Set the `synchronize` parameter to true in any one of these methods to
 lock the cache and allow a single thread to access it at a time.
 */
open class LRUCache<T: Comparable & Hashable, K>: Cache<T, K> {
    
    convenience public init(cacheName: String, totalCost t: Int) {
        self.init()
        self.cacheName = cacheName
        self.totalCost = t
    }
    
    /**
     This member stores an ordered list of the most recently used keys.
     - todo: switch to a hashmap linked list to provide O(1) search, and insert
     */
    fileprivate let recentKeys = LRULinkedList<T>()
    
    /**
     This member stores the maxmium cost threshhold this data structure will tolerate.
     - Defaults to 100MB
     */
    open var totalCost = 100 * 1024 * 1024
    
    /**
     This member tracks the current data collection cost. It starts at 0
     */
    fileprivate var currentCost: Int = 0
    
    /**
     This method will systematically evict the oldest record from the data collection until the `currentCost` value
     falls below the totalCostLimitMB value
     */
    fileprivate func respectCostLimit() {
        while (currentCost > totalCost) {
            // here we want to remove the least recently used
            guard let key = recentKeys.pop() else {
                recentKeys.clear()
                self.cache.removeAll()
                currentCost = 0
                return
            }
            if let cost = cache.get(key)?.cost {
                currentCost -= cost
            }
            self.cache.removeValue(forKey: key)
        }
    }
    
    /**
     The LRUCache overrides this metod to return an ordered list of keys from the data collection
     */
    open override var keys: [T] {
        var ret = [T]()
        self.lock.synchronize {
            ret = self.recentKeys.all()
        }
        return ret
    }
    
    /**
     The LRUCache overrides this metod to return an ordered list of entries from the data collection
     */
    open override var entries: [CacheEntry<K>] {
        var ret = [CacheEntry<K>]()
        self.lock.synchronize {
            ret = self.recentKeys.all().compactMap() { self.cache.get($0) }
        }
        return ret
    }
    
    /**
     The LRUCache overrides this metod to return an ordered list of entries from the data collection
     */
    open override func get(entryForKey key: T, synchronize: Bool = false) -> CacheEntry<K>? {
        let ret = super.get(entryForKey: key, synchronize: synchronize)
        if ret != nil {
            self.recentKeys.append(value: key)
        }
        return ret
    }
    
    open override func put(key: T, entry: CacheEntry<K>, synchronize: Bool = false) {
        super.put(key: key, entry: entry, synchronize: synchronize)
        self.currentCost += entry.cost
        self.recentKeys.append(value: key)
        self.respectCostLimit()
    }
    
    open func put(key: T, value: K, cost: Int, synchronize: Bool = false) {
        self.put(key: key, entry: CacheEntry<K>(value: value, cost: cost), synchronize: synchronize)
    }
    
    open override func remove(entryForKey key: T, synchronize: Bool = false) -> CacheEntry<K>? {
        let ret = super.remove(entryForKey: key, synchronize: synchronize)
        var _ = self.recentKeys.remove(value: key)
        self.currentCost -= ret?.cost ?? 0
        return ret
    }
    
    open override func removeAllCache(synchronize: Bool = false) {
        super.removeAllCache(synchronize: synchronize)
        self.recentKeys.clear()
        self.currentCost = 0
    }
    
    open override func setCache(cache: [T : CacheEntry<K>]?, synchronize: Bool = false) {
        super.setCache(cache: cache, synchronize: synchronize)
        for (key, value) in self.cache {
            recentKeys.append(value: key)
            currentCost += value.cost
        }
    }
    
}



