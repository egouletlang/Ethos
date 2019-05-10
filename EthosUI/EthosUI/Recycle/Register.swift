//
//  Register.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 4/30/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import EthosUtil


public enum RecycleModels: String {
    case base = "BASE"
    case label = "LabelRecycleModel"
}

fileprivate let baseRowView = BaseRecycleView(frame: CGRect.zero)

public extension BaseRecycleView {
    
    class func build(id: String, forMeasurement: Bool) -> BaseRecycleView {
        if forMeasurement {
            return baseRowView
        }
        return BaseRecycleView(frame: CGRect.zero)
    }
}


fileprivate let baseRecycleTVCell = BaseRecycleTVCell(reuseIdentifier: RecycleModels.base.rawValue)

public extension BaseRecycleTVCell {
    
    class func buildIdentifier(id: String, forWidth width: CGFloat) -> String {
        return "\(id):\(width)"
    }
    
    class func build(id: String, width: CGFloat, forMeasurement: Bool) -> BaseRecycleTVCell {
        if forMeasurement {
            return baseRecycleTVCell
        }
        return BaseRecycleTVCell(reuseIdentifier: RecycleModels.base.rawValue)
    }
}
