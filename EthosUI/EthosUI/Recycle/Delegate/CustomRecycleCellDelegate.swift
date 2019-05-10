//
//  CustomRecycleCellDelegate.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 5/8/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

public protocol CustomRecycleCellDelegate: NSObjectProtocol {
    func getCellsToRegister() -> [(Swift.AnyClass?, String)]
}

public protocol CustomTVCellDelegate: CustomRecycleCellDelegate {
    func getOrBuildCell(tableView: UITableView, model: BaseRecycleModel, width: CGFloat,
                        forMeasurement: Bool) -> BaseRecycleTVCell?
}
