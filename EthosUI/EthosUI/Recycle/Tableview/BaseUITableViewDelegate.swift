//
//  BaseUITableViewDelegate.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 5/8/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

@objc 
public protocol BaseUITableViewDelegate: NSObjectProtocol {
    func tapped(model: BaseRecycleModel, view: BaseRecycleView, tableview: BaseUITableView)
    func longPressed(model: BaseRecycleModel, view: BaseRecycleView, tableview: BaseUITableView)
    @objc optional func newScrollOffset(offset: CGFloat, tableview: BaseUITableView)
}
