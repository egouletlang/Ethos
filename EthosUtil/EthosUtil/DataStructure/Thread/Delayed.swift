//
//  Delayed.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

/**
 The Delayed class is designed to wrap a value, buffer a series of modifications to that value and provide a single
 callback once the value has stabilized.
 */
open class Delayed<T>: NSObject {
    
    public typealias StabilizedResultCallback = (T?) -> Void
    
    // MARK: - Builders & Constructors
    public init(delay: TimeInterval) {
        self.delay = delay
    }
    
    /**
     This method allows you to set a StabilizedResultCallback value
     - returns: current instace
     */
    @discardableResult public func with(callback: @escaping StabilizedResultCallback) -> Delayed {
        self.callback = callback
        return self
    }
    
    //MARK: - State Variables
    /**
     This member determines the time required between two modifications requests for the value to be considered stable
     */
    private var delay: TimeInterval
    
    /**
     This member is used to track time
     */
    private var timer: Timer?
    
    /**
     This member tracks the current value
     */
    private var value: T?
    
    /**
     This member holds the method that should be called when the value stabilizes
     */
    private var callback: StabilizedResultCallback? = nil
    
    // MARK: - Operators
    /**
     This methods sets a new value for the delayed object.
     
     - parameters:
        - value: A value that should be passed back when the timer expires
     */
    open func set(value: T?) {
        ThreadHelper.main {
            self.timer?.invalidate()
            self.value = value
            self.timer = Timer.scheduledTimer(timeInterval: self.delay, target: self,
                                              selector: #selector(Delayed.selectorFireTimer),
                                              userInfo: nil, repeats: false)
        }
    }
    
    // MARK: - Selectors
    /**
     This is the selector method called when the timer expires. It is safe to call this method if
     you want to **force** the `fire` closure to execute.
     */
    @objc open func selectorFireTimer() {
        self.callback?(self.value)
    }
    
    // MARK: - Clean up
    open func cleanUp() {
        self.callback = nil
    }
    
}


