//
//  Lock.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

/**
 The Lock Class provides a simple way to lock and synchronize blocks of code
 - important: Be sure to use [weak self] if you need to reference that self in your block
 */
open class Lock {
    
    public init() {}
    
    /**
     Locks or synchronizes access to a block across threads. Behaves similarly to the
     synchronize(this) { ... } codeblock in Java
     
     - important: Be sure to use [weak self] if you need to reference that self in your block
     
     - parameters:
     - blk: The block of code that should be synchronized or locked using this lock object
     */
    open func synchronize(blk: () -> Void) {
        objc_sync_enter(self)
        blk()
        objc_sync_exit(self)
    }
}
