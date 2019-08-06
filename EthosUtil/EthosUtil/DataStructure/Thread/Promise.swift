//
//  Promise.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

/**
 The Promise Class converts an asynchronous process into a synchronous process
 - important: Be sure to use [weak self] if you need to reference that self in your block
 */
open class Promise<T> {
    
    // MARK: - Constants & Types
    fileprivate let BACKGROUND_THREAD_NAME = "__RESERVED__.Promise"
    
    fileprivate let SLEEP_TIME: TimeInterval = 0.1
    
    /**
     - parameters:
        - task: The task that will fulfill the promise
     */
    public init(task: @escaping (Promise<T>) -> Void) {
        ThreadHelper.checkApp(BACKGROUND_THREAD_NAME) { task(self) }
    }
    
    // MARK: - State Variables
    
    /**
     This member holds the promise result
     */
    fileprivate var result: T?
    
    /**
     This member determines whether the promise has been fulfilled
     - note: the `result` member may still be `nil`
     */
    fileprivate var isResultReady = false
    
    /**
     This method should be called to set the result when the promise task is complete
     
     - parameters:
        - result: the promise task result
     */
    open func fulfill(_ result: T?) {
        self.result = result
        self.isResultReady = true
    }
    
    /**
     This method gets the result of the promise.
     
     - note: It is a blocking call and will block until the result is ready or the timeout is reached
     
     - parameters:
        - timeout: the maximum amount of time in **seconds** this method is allowed to wait for the promise to finish
     
     - returns: A result or nil if the promise task does not complete in time
     */
    open func get(timeout: TimeInterval = 5) -> T? {
        var timeSlept: TimeInterval = 0
        while (!isResultReady && timeSlept < timeout) {
            Thread.sleep(forTimeInterval: SLEEP_TIME)
            timeSlept += SLEEP_TIME
        }
        return result
    }
}
