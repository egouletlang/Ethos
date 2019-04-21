//
//  LifeCycleInterface.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 4/20/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

@objc
public protocol LifeCycleInterface {
    // Initialize
    @objc optional func initialize()
    func createLayout()
    
    // Updates
    func frameUpdate()
    @objc optional func frameWidthUpdate()
    @objc optional func frameHeightUpdate()
    
    // CleanUp
    @objc optional func cleanUp()
    @objc optional func destroy()
}
