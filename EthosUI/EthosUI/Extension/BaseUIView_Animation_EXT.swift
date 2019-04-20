//
//  BaseUIView_EXT_Anim.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 4/20/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

extension BaseUIView {
    
    // MARK: Constants & Types
    public static let ANIMATION_DURATION: TimeInterval = 0.3
    
    open func animate(_ block: @escaping ()->Void) {
        UIView.animate(
            withDuration: BaseUIView.ANIMATION_DURATION,
            delay: 0,
            options: UIView.AnimationOptions.beginFromCurrentState,
            animations: block,
            completion: nil)
    }
}
