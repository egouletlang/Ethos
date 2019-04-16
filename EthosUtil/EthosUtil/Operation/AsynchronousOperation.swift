//
//  AsynchronousOperation.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

/**
 The AsynchronousOperation class supports doing asynchronous work. This lets you chain operations and seperate code to
 improve reusability.
 
 The class wraps the main(..) function and waits for an explicit call to deactivate(..) before the operation
 'completes'. Having said that, the operation is not allowed to run indefinitly. It uses two parameters SLEEP_TIME,
 COUNT_MAX to determine how long the thread will sleep and how many times it will sleep before abandoning respectively
 */
open class AsynchronousOperation: Operation {
    
    // MARK: - Constants & Types
    /**
     This constant determines the number of cycles to wait before stopping the operation.
     
     - note: The 'COUNT_MAX' and 'SLEEP_TIME' constants are part of a fail-safe mechanism to prevent any child Operation
     from blocking a queue, if the thread is left active for any reason.
     */
    fileprivate static let COUNT_MAX = 500
    
    /**
     This constant determines the amount of time (in seconds) to sleep between cycles=
     
     - note: The 'COUNT_MAX' and 'SLEEP_TIME' constants are part of a fail-safe mechanism to prevent any child Operation
     from blocking a queue, if the thread is left active for any reason.
     */
    fileprivate static let SLEEP_TIME: TimeInterval = 0.1
    
    // MARK: - Singleton & Delegate
    /**
     A delegate to handle the operation result once it is ready
     */
    open weak var asynchronousOperationDelegate: AsynchronousOperationDelegate?
    
    // MARK: - State Variables
    /**
     This member tracks whether the operation is still active
     */
    private var operationActive = false
    
    //MARK: - Lifecycle
    /**
     This method sets the operation state to active
     */
    private func activate() {
        self.operationActive = true
    }
    
    /**
     This method sets the operation state to inactive, and uses the delegate to "complete" the action
     
     - parameters:
        - result: the operation result
     */
    open func deactivate(result: Any?) {
        self.operationActive = false
        self.asynchronousOperationDelegate?.complete(result: result)
    }
    
    /**
     This method sleeps for `SLEEP_TIME` until either deactivate(..) is called or the number of sleep cycles reaches
     COUNT_MAX
     
     - Note: If TTL is exceeded, the operation is NOT cancelled.
     */
    private func waitForDeactivate() {
        var count = 0
        while (operationActive && count < AsynchronousOperation.COUNT_MAX) {
            Thread.sleep(forTimeInterval: AsynchronousOperation.SLEEP_TIME)
            count += 1
        }
    }
    
    /**
     This class overrides the main method to
     - activate()
     - run()
     - waitForDeactivate()
     */
    override open func main() {
        self.activate()
        self.run()
        self.waitForDeactivate()
    }
    
    // MARK: - “Abstract” Methods (Override these)
    /**
     Treat as main(..)
     - important: be sure to ALWAYS call deactivate(..), even when there is an error
     */
    open func run() {
        assert(false, "You must overriding run(...)")
    }
}


