//
//  FirstResponderInterface.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 4/20/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

@objc
public protocol FirstResponderInterface {
    @objc optional func allowFirstResponderResign()
    @objc optional func preventFirstResponderResign()
}
