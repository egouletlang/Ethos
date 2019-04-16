//
//  ModuleState.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

/**
 The ModuleState Class is a wrapper around UserDefaults. It provides a simple interface for storing and retrieving
 [Boolean, Integer, Double, String, Data] types.
 
 - important: It is easy to have key collisions, and there are no checks for this. Don't use this class `as is`. Instead
 inherit from it, creating an application specific state object. Be sure to override the `getFileName(..)`
 method with a unique string.
 */
open class ModuleState {
    
    // MARK: - Constants & Types
    
    fileprivate let BOOLEAN_NIL_VALUE = 0
    fileprivate let BOOLEAN_TRUE_VALUE = 1
    fileprivate let BOOLEAN_FALSE_VALUE = 2
    
    fileprivate static let KEY_URI = "key://"
    fileprivate static let DEFAULT_STATE_BUNDLE_PATH = "__RESERVED__.default_state_bundle_path"
    
    // MARK: - Class Methods
    /**
     This method creates a key that is prefixed with `KEY_URI` to make it easily identifiable
     
     - parameters:
        - name: a unique identifier
     
     - returns: the identifiable key
     */
    open class func createKey(_ name: String) -> String {
        return ModuleState.KEY_URI + name
    }
    
    // MARK: - Builders & Constructors
    public init() {
        assert(self.name != ModuleState.DEFAULT_STATE_BUNDLE_PATH, "You must overriding getFileName(...)")
        
        userDefaults = UserDefaults(suiteName: self.suiteName + "://" + self.name)
        if !(userDefaults?.synchronize() ?? false) {
            print("NSUserDefaults failed to synchronize content")
        }
        cache = userDefaults?.dictionaryRepresentation() ?? [:]
    }
    
    // MARK: - State Variables
    /**
     This member holds the UserDefault reference
     */
    private var userDefaults: UserDefaults?
    
    /**
     UserDefaults do not delete keys synchronously. This member acts as a buffer and keeps the state in sync with the
     system's true state
     */
    private var cache = [String: Any]()
    
    /**
     This property provides a namespace to separate the state of one app from others
     */
    private var suiteName: String {
        return DeviceHelper.appName ?? "no.app"
    }
    
    /**
     This property provides a namespace for the state vault. Override this and make it unique.
     */
    open var name: String {
        return self.getName()
    }
    
    //MARK: - Boolean Interface
    /**
     This method gets a Bool value for `key` or return `def`
     
     - parameters:
         - key: target key
         - def: default value if the key does not exists
     
     - returns: the stored Bool
     */
    open func getValue(key: String,_ def: Bool) -> Bool {
        let key = ModuleState.createKey(key)
        let value = self.getValue(key: key, BOOLEAN_NIL_VALUE)
        return (value != BOOLEAN_NIL_VALUE) ? (value == BOOLEAN_TRUE_VALUE) : def
    }
    
    /**
     This method sets a Bool value for `key`
     
     - parameters:
         - key: new key
         - value: new value
     */
    open func setValue(key: String,_ value: Bool) {
        let key = ModuleState.createKey(key)
        self.setValue(key: key, (value) ? (BOOLEAN_TRUE_VALUE) : (BOOLEAN_FALSE_VALUE))
    }
    
    //MARK: - Unwrapped Types (Integer, Double, ... )
    /**
     This method gets a unwrapped value for `key` or return `def`
     
     - parameters:
         - key: target key
         - def: default value if the key does not exists
     
     - returns: the stored unwrapped value
     */
    open func getValue<T>(key: String,_ def: T) -> T {
        let key = ModuleState.createKey(key)
        if let val = self.cache.get(key) as? T {
            return val
        }
        return def
    }
    
    /**
     This method sets an unwrapped value for `key`
     
     - parameters:
         - key: new key
         - value: new value
     */
    open func setValue<T>(key: String,_ value: T) {
        let key = ModuleState.createKey(key)
        self.cache[key] = value
        userDefaults?.set(value, forKey: key)
    }
    
    //MARK: - Nilable Types (Integer, Double, ... )
    /**
     This method gets a nilable value for `key` or return `def`
     
     - parameters:
     - key: target key
     - def: default value if the key does not exists
     
     - returns: the stored nilable value
     */
    open func getValue<T>(key: String,_ def: T?) -> T? {
        let key = ModuleState.createKey(key)
        if let val = self.cache.get(key) as? T {
            return val
        }
        return def
    }
    
    /**
     This method sets a String value for `key`
     
     - parameters:
         - key: new key
         - value: new value
     */
    open func setValue<T>(key: String,_ value: T?) {
        let key = ModuleState.createKey(key)
        if let v = value {
            self.cache[key] = v
            userDefaults?.set(v, forKey: key)
        } else {
            self.cache.removeValue(forKey: key)
            userDefaults?.removeObject(forKey: key)
        }
    }
    
    // MARK: - Clean up
    /**
     This method clears all keys that start with a substring
     
     - parameters:
        - with: a unique identifier
     */
    open func clearKeys(with: String) {
        userDefaults?.dictionaryRepresentation().keys
            .filter() { $0.startsWith(ModuleState.createKey(with)) }
            .forEach { (key) in
                cache.removeValue(forKey: key)
                userDefaults?.removeObject(forKey: key)
        }
    }
    
    /**
     This method clears all keys
     */
    open func clearAll() {
        self.clearKeys(with: ModuleState.KEY_URI)
    }
    
    // MARK: - “Abstract” Methods (Override these)
    /**
     This method determines the namespace for the state vault. Override this and make it unique.
     */
    open func getName() -> String {
        return ModuleState.DEFAULT_STATE_BUNDLE_PATH
    }
}

