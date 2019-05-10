//
//  BaseRecycleCellDelegate.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 5/8/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

public protocol BaseRecycleCellDelegate: NSObjectProtocol {
    func active(view: BaseRecycleView)
    func tapped(model: BaseRecycleModel, view: BaseRecycleView)
    func longPressed(model: BaseRecycleModel, view: BaseRecycleView)
}

public protocol BaseRecycleTVCellDelegate: BaseRecycleCellDelegate {
    func getTableView() -> UITableView?
}
