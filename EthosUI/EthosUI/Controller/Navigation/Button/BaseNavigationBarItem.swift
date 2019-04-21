//
//  BaseNavigationItem.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 4/20/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

open class BaseNavigationBarItem {
    
    public init(target: Any, selector: Selector) {
        self.target = target
        self.selector = selector
    }
    
    open var target: Any
    
    open var selector: Selector
    
    open var button: UIBarButtonItem? {
        return nil
    }
    
}
