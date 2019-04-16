//
//  EthosUtilConfigDelegate.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

@objc public protocol EthosUtilConfigDelegate: ModuleConfigDelegate {
    @objc optional func getLocale() -> Locale?
}
