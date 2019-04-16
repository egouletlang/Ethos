//
//  LogHelperDelegate.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

@objc public protocol LogHelperDelegate: NSObjectProtocol {
    
    func log(msg: String, tag: String)
    @objc optional func checkConditionFailed(msg: String)
    @objc optional func info(msg: String)
    @objc optional func debug(msg: String)
    @objc optional func warning(msg: String)
    @objc optional func error(msg: String)
    
}
