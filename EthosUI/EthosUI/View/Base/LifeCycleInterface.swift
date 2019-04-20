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
    @objc optional func initialize()
    func createLayout()
    func frameUpdate()
    @objc optional func destroy()
    @objc optional func frameWidthUpdate()
    @objc optional func frameHeightUpdate()
}
