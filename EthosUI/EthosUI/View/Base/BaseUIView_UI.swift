//
//  BaseUIView_UI.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 5/9/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import EthosUtil

public extension BaseUIView {
    
    override func setNeedsDisplay() {
        ThreadHelper.checkMain {
            super.setNeedsDisplay()
        }
    }
    
}
