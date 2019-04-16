//
//  UniqueOperationQueue.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

/**
 The UniqueOperationQueue class runs asynchronous and unique operations for better resource management. If a task is
 request multiple times, the class associates multiple callbacks with a unique operation instead of adding multiple
 operations to the queue
 */
open class UniqueOperationQueue<T>: OperationQueue, UniqueOperationDelegate {
    
    // MARK: - Constants & Types
    /**
     This is a typealias for the callback closure
     */
    public typealias CompletionBlock = (T?) -> Void
    
    // MARK: - Builders & Constructors
    public convenience init(name: String, concurrentCount: Int) {
        self.init()
        self.name = name
        self.maxConcurrentOperationCount = concurrentCount
    }
    
    // MARK: - State variables
    /**
     This member maps an id to a list of callbacks
     */
    private var callbackMap = [String: [CompletionBlock]]()
    
    /**
     This member is used to synchronize the callbackMap operations
     */
    private var lock = Lock()
    
    // MARK: - Operations
    /**
     This method starts a unique operation or adds a callback to an existing one
     - parameters:
         - op: The unique operator you want to call
         - callback: A closure where you want to receive your data
     */
    open func addOperation(op: UniqueOperation, callback: @escaping CompletionBlock) {
        // Lock and add callback
        var startOperation = false
        guard let id = op.getUniqueId() else { return }
        lock.synchronize { [weak self] in
            if var callbacks = self?.callbackMap.get(id) {
                callbacks.append(callback)
            } else {
                self?.callbackMap[id] = [callback]
                startOperation = true
            }
        }
        
        // Start if necessary
        if startOperation {
            op.uniqueOperationDelegate = self
            super.addOperation(op)
        }
        
    }
    
    // MARK: - UniqueOperationDelegate Methods
    open func complete(id: String?, result: Any?) {
        // Lock and get current list of callbacks
        var operationCallbacks = [CompletionBlock]()
        lock.synchronize { () -> () in
            if  let i = id, let callbacks = self.callbackMap[i] {
                operationCallbacks = callbacks
                self.callbackMap.removeValue(forKey: i)
            }
        }
        
        // Dispatch to each callback
        let res = result as? T
        for callback in operationCallbacks {
            ThreadHelper.background() {
                callback(res)
            }
        }
    }
}

