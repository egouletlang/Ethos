//
//  EthosUILabelDelegate.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 4/20/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

@objc
public protocol EthosUILabelDelegate: NSObjectProtocol {
    @objc optional func interceptUrl(_ url: String) -> Bool
}
