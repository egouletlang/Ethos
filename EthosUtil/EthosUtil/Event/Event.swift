//
//  Event.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

open class Event {
    
    public init(name: String) {
        self.name = name
    }
    
    private var name: String
    
    open var notificationName: Notification.Name {
        return NSNotification.Name("event:" + name)
    }
    
    open func emit(userInfo: [AnyHashable: Any]? = nil) {
        EventHelper.shared.emit(name: self.notificationName, userInfo: userInfo)
    }
    
    open func subscribe(observer: Any, selector: Selector) {
        EventHelper.shared.subscribe(name: self.notificationName, observer: observer, selector: selector)
    }
    
    open func unsubscribe(observer: Any) {
        EventHelper.shared.unsubscribe(name: self.notificationName, observer: observer)
    }
    
}
