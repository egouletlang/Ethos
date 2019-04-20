//
//  EthosUIConfigDelegate.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 4/20/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import EthosUtil

@objc public protocol EthosUIConfigDelegate: ModuleConfigDelegate {
    
    // Common Colors
    @objc optional func getBorderColor() -> UIColor
    
    // Theme Colors
    @objc optional func getPrimaryColor() -> UIColor
    
    
    
}
