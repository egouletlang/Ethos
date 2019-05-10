//
//  LabelRecycleTVCell.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 5/10/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

open class LabelRecycleTVCell: BaseRecycleTVCell {
    
    override open var cell: BaseRecycleView {
        return LabelRecycleView(frame: CGRect.zero)
    }
    
}
