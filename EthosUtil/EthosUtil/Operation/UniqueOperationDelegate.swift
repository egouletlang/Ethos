//
//  UniqueOperationDelegate.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

public protocol UniqueOperationDelegate: NSObjectProtocol {
    func complete(id: String?, result: Any?)
}
