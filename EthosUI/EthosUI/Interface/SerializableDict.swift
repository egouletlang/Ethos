//
//  SerializableDict.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 5/1/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

public protocol SerializableDict {
    func buildSerializableDict() -> [String: Any]
    func fromSerializableDict(_ dict: [String: Any])
}
