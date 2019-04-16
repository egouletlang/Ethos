//
//  AsynchronousOperationDelegate.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

public protocol AsynchronousOperationDelegate: NSObjectProtocol {
    func complete(result: Any?)
}
