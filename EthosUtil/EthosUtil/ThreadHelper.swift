//
//  ThreadHelper.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

/**
 ThreadHelper contains a series of useful threading-related methods.
 */
open class ThreadHelper {
    
    // MARK: - Dispatch Methods
    open class func main(block: @escaping () -> Void) {
        DispatchQueue.main.async {
            block()
        }
    }
    
    open class func background(block: @escaping () -> Void) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            block()
        }
    }
    
    // MARK: - Correct Thread Methods
    open class func checkMain(block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            main(block: block)
        }
    }
    
    open class func checkBackground(block: @escaping () -> Void) {
        if !Thread.isMainThread {
            block()
        } else {
            background(block: block)
        }
    }
    
    // MARK: - Synchronize Method
    open class func synchronize(lock: Lock, block: @escaping () -> Void) {
        checkBackground {
            lock.synchronize(blk: block)
        }
    }
    
    // MARK: - Application Specific Methods
    fileprivate static let ANONYMOUS_THREAD_NAME = "__RESERVED__.anonymous_thread"
    
    fileprivate static var applicationQueues = [String: DispatchQueue]()
    
    open class func getOrCreateApplicationQueue(name: String) -> DispatchQueue? {
        return self.applicationQueues.get(name) { () -> DispatchQueue? in
             return DispatchQueue(label: name)
        }
    }
    
    open class func removeApplicationQueue(name: String) {
        self.applicationQueues.removeValue(forKey: name)
    }
    
    open class func app(_ name: String?, block: @escaping () -> Void) {
        getOrCreateApplicationQueue(name: name ?? ANONYMOUS_THREAD_NAME)?.async(execute: block)
    }
    
}

