//
//  ReusableViewInterface.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 4/20/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

public protocol ReusableViewInterface {
    func prepareForReuse()
    func onScreen()
    func offScreen()
    func cleanUp()
}
