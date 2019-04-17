//
//  EthosTextConfigDelegate.swift
//  EthosText
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import EthosUtil

@objc public protocol EthosTextConfigDelegate: ModuleConfigDelegate {
    // Font
    @objc optional func getRegularFont() -> UIFont
    @objc optional func getBoldFont() -> UIFont
    @objc optional func getItalicFont() -> UIFont
}
