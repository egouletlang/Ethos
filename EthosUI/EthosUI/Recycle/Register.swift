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

fileprivate let recycleViews: [RecycleModels: BaseRecycleView] = {
    return [
        .label: LabelRecycleView(frame: CGRect.zero)
    ]
}()

fileprivate let baseRecycleView = BaseRecycleView(frame: CGRect.zero)

public extension BaseRecycleView {
    
    class func build(id: String, forMeasurement: Bool) -> BaseRecycleView {
        let modelId = RecycleModels(rawValue: id) ?? .base
        
        if forMeasurement {
            return recycleViews.get(modelId) ?? baseRecycleView
        }
        
        switch(modelId) {
        case .label:
            return LabelRecycleView(frame: CGRect.zero)
        default:
            return BaseRecycleView(frame: CGRect.zero)
        }
        
    }
}

fileprivate let recycleTVCells: [RecycleModels: BaseRecycleTVCell] = {
    return [
        .label: LabelRecycleTVCell(modelIdentifier: .label)
    ]
}()

fileprivate let baseRecycleTVCell = BaseRecycleTVCell(modelIdentifier: .base)

public extension BaseRecycleTVCell {
    
    class func buildIdentifier(id: String, forWidth width: CGFloat) -> String {
        return "\(id):\(width)"
    }
    
    class func build(id: String, width: CGFloat, forMeasurement: Bool) -> BaseRecycleTVCell {
        let modelId = RecycleModels(rawValue: id) ?? .base
        
        if forMeasurement {
            return recycleTVCells.get(modelId) ?? baseRecycleTVCell
        }
        
        switch(modelId) {
        case .label:
            return LabelRecycleTVCell(modelIdentifier: .label)
        default:
            return BaseRecycleTVCell(modelIdentifier: .base)
        }
        
    }
}
