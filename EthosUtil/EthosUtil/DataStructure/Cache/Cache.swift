//
//  Cache.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

/**
 The Cache class creates a simple data structure to store an addressable data collection in memory. It leverage the
 CacheEntry class but does not consider entry cost to optimize its caching solution.
 
 - important: Other caching solutions in the Ethos project should inherit from this class to maintain a consistent
 interface
 
 - TODO: Add implicit memory limit.
 
 ## CacheEntry Methods
 - `put(key: T, entry: CacheEntry<K>, ...)`
 - `get(entryForKey key: T, ...) -> CacheEntry<K>?`
 - `remove(entryForKey key: T, ...) -> CacheEntry<K>?`
 
 ## Data Methods
 - `put(key: T, value: K, ... )`
 - `get(key: T, ... ) -> K?`
 
 ## File System Functionality
 - `save()`
 - `load()`
 - `delete()`
 
 By default, this cache is not thread safe. Set the `synchronize` parameter to true in any one of these methods to
 lock the cache and allow a single thread to access it at a time.
 */
open class Cache<T: Comparable & Hashable, K> {
    
    // MARK: - Builders & Constructors
    public init() {}
    
    /**
     This constructor initializes the cache instance using a `cacheName` parameter. Be sure to make the value of this
     parameter unique, as it will be used as the file name when storing the data structure on the file system.
     */
    convenience public init(cacheName: String) {
        self.init()
        self.cacheName = cacheName
    }
    
    // MARK: - State Variables
    /**
     This member stores a name associated with this instance. It should be unique because it will also server as the
     file name when storing the data structure on the file system.
     */
    open var cacheName: String?
    
    /**
     This member is used to synchronize cache operations
     */
    let lock = Lock()
    
    /**
     This member is the "in-memory" cache
     */
    var cache = [T: CacheEntry<K>]()
    
    /**
     This property returns a list of the cache keys
     */
    open var keys: [T] {
        return Array(self.cache.keys)
    }
    
    /**
     This property returns a list of the cache entries
     */
    open var entries: [CacheEntry<K>] {
        return Array(self.cache.values)
    }
    
    /**
     This property returns a list of the cache values
     */
    open var values: [K] {
        return self.entries.compactMap() { $0.value }
    }
    
    // MARK: - Operations
    /**
     This method gets a CacheEntry for a given key
     
     - parameters:
         - entryForKey: Key you want to find
         - synchronize: Set to true to make this call thread-safe. defaults to False.
     
     - returns: A CacheEntry for a given key, if it exists
     */
    open func get(entryForKey key: T, synchronize: Bool = false) -> CacheEntry<K>? {
        if (synchronize) {
            var ret: CacheEntry<K>?
            self.lock.synchronize { [weak self] in
                ret = self?.get(entryForKey: key, synchronize: false)
            }
            return ret
        }
        
        return self.cache.get(key)
    }
    
    /**
     This method sets the CacheEntry associated with a key. If a CacheEntry for that key already exists, it is replaced
     
     - parameters:
         - key: Key you want to add
         - entry: CacheEntry you want to add
         - synchronize: Set to true to make this call thread-safe. defaults to False.
     */
    open func put(key: T, entry: CacheEntry<K>, synchronize: Bool = false) {
        if (synchronize) {
            self.lock.synchronize { [weak self] in
                self?.put(key: key, entry: entry, synchronize: false)
            }
            return
        }
        
        self.cache[key] = entry
    }
    
    
    /**
     This method removes a (key, CacheEntry) pair from the data collection.
     
     - parameters:
         - entryForKey: Key you want to remove
         - synchronize: Set to true to make this call thread-safe. defaults to False.
     
     - returns: the cache entry if it exists
     */
    @discardableResult
    open func remove(entryForKey key: T, synchronize: Bool = false) -> CacheEntry<K>? {
        if (synchronize) {
            var ret: CacheEntry<K>?
            self.lock.synchronize { [weak self] in
                ret = self?.remove(entryForKey: key, synchronize: false)
            }
            return ret
        }
        
        return self.cache.removeValue(forKey: key)
    }
    
    /**
     This method replaces the existing data collection with a new one.
     
     - parameters:
         - cache: New data collection that should be used instead of the current one
         - synchronize: Set to true to make this call thread-safe. defaults to False.
     */
    open func setCache(cache: [T: CacheEntry<K>]?, synchronize: Bool = false) {
        if (synchronize) {
            self.lock.synchronize { [weak self] in
                self?.setCache(cache: cache, synchronize: false)
            }
            return
        }
        
        guard let c = cache else { return }
        self.cache = c
    }
    
    /**
     This method removes all (key, CacheEntry) pairs from the data collection.
     
     - parameters:
        - synchronize: Set to true to make this call thread-safe. defaults to False.
     */
    open func removeAllCache(synchronize: Bool = false) {
        if (synchronize) {
            self.lock.synchronize { [weak self] in
                self?.removeAllCache(synchronize: false)
            }
            return
        }
        
        self.cache.removeAll()
    }
    
    // MARK: - Data methods
    /**
     This method gets the data for a given key
     
     - parameters:
         - key: key you want to find
         - synchronize: Set to true to make this call thread-safe. defaults to False.
     
     - returns: The cached data if the key exist
     */
    open func get(key: T, synchronize: Bool = false) -> K? {
        return self.get(entryForKey: key, synchronize: synchronize)?.value
    }
    
    /**
     This method sets the `value` associated with a key. If a value for that key already exists, it is replaced
     
     - parameters:
         - key: Key you want to add
         - value: Value you want to add
         - synchronize: Set to true to make this call thread-safe. defaults to False.
     */
    open func put(key: T, value: K, synchronize: Bool = false) {
        self.put(key: key, entry: CacheEntry<K>(value: value), synchronize: synchronize)
    }
    
    /**
     This method removes a (key, CacheEntry) pair from the data collection.
     
     - parameters:
         - key: Key you want to remove
         - synchronize: Set to true to make this call thread-safe. defaults to False.
     
     - returns: the cache entry if it exists
     */
    @discardableResult
    open func remove(key: T, synchronize: Bool = false) -> K? {
        return self.remove(entryForKey: key, synchronize: synchronize)?.value
    }
    
    // MARK: - Persist methods
    /**
     This method saves the data collection state to a file
     - important: The `cacheName` parameter determines the filename. Make this value unique to avoid collisions
     */
    open func save() {
        guard let name = self.cacheName, !self.cache.isEmpty else {
            return
        }
      
        let fileHandle = FileSystemHelper.shared.getFileSystemFileSystemReference(resourceName: name, type: "cache")
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: self.cache, requiringSecureCoding: false)
            try fileHandle?.overwrite(data: data)
        } catch {
            LogHelper.shared.log(msg: error.localizedDescription, tag: .Error)
        }
    }
    
    /**
     This method restores the data collection state from a file, if it exists
     - important: The `cacheName` parameter determines the filename. Make this value unique to avoid collisions
     */
    open func load() {
        do {
            guard let name = self.cacheName else { return }
            
            let fileHandle = FileSystemHelper.shared.getFileSystemFileSystemReference(resourceName: name, type: "cache")
            guard let data = fileHandle?.getData() else {
                return
            }
            
            let dictionary = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [T : CacheEntry<K>]
            self.setCache(cache: dictionary)
        } catch {
            LogHelper.shared.log(msg: error.localizedDescription, tag: .Error)
        }
    }
    
    /**
     This method deletes a file containing the data collection state, if it exists
     - important: The `cacheName` parameter determines the filename. Make this value unique to avoid collisions
     */
    open func delete() {
        do {
            guard let name = self.cacheName else { return }
            
            self.setCache(cache: [:])
            
            let fileHandle = FileSystemHelper.shared.getFileSystemFileSystemReference(resourceName: name, type: "cache")
            try fileHandle?.delete()
        } catch {
            LogHelper.shared.log(msg: error.localizedDescription, tag: .Error)
        }
    }
    
}
