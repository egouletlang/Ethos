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
    
    // Font Metadata
    @objc optional func getFontSize() -> CGFloat
    @objc optional func getFontColor() -> UIColor?
    
    // Component Parameters
    @objc optional func getLinkColor() -> UIColor
}
