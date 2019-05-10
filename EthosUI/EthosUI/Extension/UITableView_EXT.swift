//
//  UITableView_EXT.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 5/8/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

public extension UITableView {
    
    func isIndexPathValid(_ index: IndexPath) -> Bool {
        return (index.section <= self.numberOfSections) && (index.row <= self.numberOfRows(inSection: index.section))
    }
    
}
