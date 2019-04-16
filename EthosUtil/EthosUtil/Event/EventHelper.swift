//
//  EventHelper.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

open class EventHelper {
    
    // MARK: - Builders & Constructors
    private init() {}
    
    // MARK: - Singleton & Delegate
    public static let shared = EventHelper()
    
    /**
     This method will publish a named event and deliver to each observer the provided dictionary.
     - note: this method will run on a background thread
     - parameters:
        - name: Event name
        - userInfo: An dictionary delivered to each observer
     */
    open func emit(name: NSNotification.Name, userInfo: [AnyHashable: Any]?) {
        ThreadHelper.background {
            NotificationCenter.default.post(name: name, object: nil, userInfo: userInfo)
        }
    }
    
    /**
     This method will add an observer for a named event
     - parameters:
         - name: event name
         - observer: observer instance
         - selector: observer selector
     */
    open func subscribe(name: NSNotification.Name, observer: Any, selector: Selector) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: name, object: nil)
    }
    
    /**
     This method will remove an observer from a named event
     - parameters:
        - name: event name
        - observer: observer instance
     */
    open func unsubscribe(name: NSNotification.Name, observer: Any) {
        NotificationCenter.default.removeObserver(observer, name: name, object: nil)
    }
    
    /**
     This method will remove an observer from all its events
     - parameters:
        - observer: subscriber instance
     */
    open func unsubscribeAll(observer: Any) {
        NotificationCenter.default.removeObserver(observer)
    }
    
}
