//
//  BaseUIViewDelegate.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 4/20/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

@objc
public protocol BaseUIViewDelegate: NSObjectProtocol {
    @objc optional func getViewController() -> UIViewController?
}
