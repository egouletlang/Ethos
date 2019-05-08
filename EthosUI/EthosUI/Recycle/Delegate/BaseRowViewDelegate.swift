//
//  BaseRowViewDelegate.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 5/5/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

@objc
public protocol BaseRecycleViewDelegate: NSObjectProtocol {
    func active(view: BaseRecycleView)
    func tapped(model: BaseRecycleModel, view: BaseRecycleView)
    func longPressed(model: BaseRecycleModel, view: BaseRecycleView)
}
