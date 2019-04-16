//
//  TaskManager.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

/**
 The TaskManager class helps coordinate a set of tasks mapping T -> V across multiple threads
 */
open class TaskManager<T, V> {
    
    // MARK: - Constants & Types
    public typealias SyncHandler = (T) -> V?
    
    public typealias AsyncHandler = (T, @escaping (V?) -> Void) -> Void
    
    // MARK: - Builders & Constructors
    public init(values: [T], def: V? = nil) {
        self.values = values
        self.results = [V?](repeating: def, count: self.values.count)
    }
    
    /**
     This method sets the task handler and returns the current instance
     
     - parameters:
     - handler: a closure that maps T to V
     
     - returns: the current TaskManager instance
     */
    open func with(syncHandler: @escaping SyncHandler) -> TaskManager<T, V> {
        self.syncHandler = syncHandler
        return self
    }
    
    /**
     This method sets the task handler and returns the current instance
     
     - parameters:
     - handler: a closure that maps T to V
     
     - returns: the current TaskManager instance
     */
    open func with(asyncHandler: @escaping AsyncHandler) -> TaskManager<T, V> {
        self.asyncHandler = asyncHandler
        return self
    }
    
    // MARK: - State Variables
    /**
     This member stores the task arguments
     */
    private var values: [T]
    
    /**
     This member stores the task results
     */
    private var results: [V?]
    
    /**
     This member represents the synchronous transformation that represents the task.
     */
    private var syncHandler: SyncHandler?
    
    /**
     This member represents the asynchronous transformation that represents the task.
     */
    private var asyncHandler: AsyncHandler?
    
    /**
     This member represents the number of completed tasks
     */
    private var completed = 0
    
    /**
     This member synchronizes the result array
     */
    private let lock = Lock()
    
    // MARK: - Operations
    /**
     This method begins applying the provided transforms to the inputs asynchronously
     
     - parameters:
        - callback: A function that should be called when all tasks have completed and the results are ready.
     */
    open func start(callback: @escaping ([V?]) -> Void) {
        guard self.values.count > 0 else {
            callback([])
            return
        }
        
        let queueName = UUID().uuidString
        for (index, task) in values.enumerated() {
            ThreadHelper.app(queueName) {
                let isDone = self.handleResult(index: index, result: self.handler(value: task))
                
                if isDone {
                    self.cleanUp()
                    ThreadHelper.background {
                        ThreadHelper.removeApplicationQueue(name: queueName)
                        callback(self.results)
                    }
                }
            }
        }
    }
    
    /**
     This method begins applying the provided transforms to the inputs synchronously
     
     - parameters:
        - timeout: the maximum amount of time in **seconds** this method is allowed to wait for the task manager to
                   finish
     
     - returns: the results
     */
    open func sync(timeout: TimeInterval) -> [V?] {
        return Promise<[V?]>() { (promise) in
                    self.start() { promise.fulfill($0) }
               }.get(timeout: timeout)
            ?? [V?](repeating: nil, count: self.values.count)
    }
    
    // MARK: - Helper Methods
    /**
     This method executes a transformation on a single piece of data
     
     - parameters:
        - value: This is the input value
     
     - returns: the transformation result or nil
     */
    private func handler(value: T) -> V? {
        if let sync = self.syncHandler {
            return sync(value)
        } else if let async = self.asyncHandler {
            return Promise<V>() { (promise) in
                async(value) { promise.fulfill($0) }
                }.get(timeout: 60)
        }
        return nil
    }
    
    /**
     This method handles a task result and checks if all tasks have completed
     
     - parameters:
         - index: task array index
         - result: task result
     
     - returns: true if all tasks have completed
     */
    private func handleResult(index: Int, result: V?) -> Bool {
        var isDone = false
        self.lock.synchronize { [weak self] in
            guard let strong = self else { return }
            strong.completed += 1
            isDone = strong.completed == strong.values.count
            strong.results[index] = result
        }
        return isDone
    }
    
    // MARK: - Clean up
    /**
     This class
     */
    open func cleanUp() {
        self.syncHandler = nil
        self.asyncHandler = nil
    }
}
