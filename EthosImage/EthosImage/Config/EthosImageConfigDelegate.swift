//
//  EthosImageConfigDelegate.swift
//  EthosImage
//
//  Created by Etienne Goulet-Lang on 4/18/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import EthosUtil

@objc public protocol EthosImageConfigDelegate: ModuleConfigDelegate {
    @objc optional func getAccessToken(host: String) -> String?
}
