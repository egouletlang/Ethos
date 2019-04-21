//
//  DeviceHelper_EXT.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 4/20/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import EthosUtil

public extension DeviceHelper {
    
    static var statusBarHeight: CGFloat {
        return DeviceHelper.statusBarFrame.height
    }
    
    static var statusBarFrame: CGRect {
        return UIApplication.shared.statusBarFrame
    }
    
    static var navigationBarHeight: CGFloat {
        return 44
    }
    
}
