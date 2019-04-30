//
//  UIHelper.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 4/20/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import EthosUtil

open class UIHelper {
    
    public static var onePixel: CGFloat = {
        if UIScreen.main.responds(to: #selector(NSDecimalNumberBehaviors.scale)) {
            let scale = UIScreen.main.scale
            if scale != 0 {
                return 1.0 / scale
            }
        }
        return 1.0
    }()    
    
    public static var statusBarHeight: CGFloat {
        return UIScreen.main.nativeBounds.height == 2436 ? 44 : 20
    }
    
    public static var navigationBarHeight: CGFloat {
        return UIScreen.main.nativeBounds.height == 2436 ? 44 : 44
    }
    
    
}
