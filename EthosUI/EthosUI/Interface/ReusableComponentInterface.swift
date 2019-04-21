//
//  ReusableComponentInterface.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 4/20/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

@objc
public protocol ReusableComponentInterface {
    @objc optional func prepareForReuse()
    @objc optional func onScreen()
    @objc optional func offScreen()
}
