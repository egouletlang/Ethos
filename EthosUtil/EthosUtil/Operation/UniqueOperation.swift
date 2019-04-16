//
//  UniqueOperation.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

/**
 The UniqueOperation class adds an identifier to the AsynchronousOperation class. This lets you see if a "task" is
 currently running. Use the UniqueOperationDelegate to handle the operation result =
 */
open class UniqueOperation: AsynchronousOperation, AsynchronousOperationDelegate {
    
    // MARK: - Constants & Types
    public typealias Delegate = UniqueOperationDelegate
    
    public override init() {
        super.init()
        self.asynchronousOperationDelegate = self
    }
    
    // MARK: - Singleton & Delegate
    /**
     A delegate to handle the unique operation result once it is ready
     */
    open weak var uniqueOperationDelegate: Delegate?
    
    // MARK: - AsynchronousOperationDelegate Methods
    public func complete(result: Any?) {
        self.uniqueOperationDelegate?.complete(id: getUniqueId(), result: result)
    }
    
    // MARK: - “Abstract” Methods (Override these)
    /**
     - important: override me
     - returns: a unique identifier for the operation
     */
    open func getUniqueId() -> String? {
        return nil
    }
}
