//
//  BaseUIView_Anim.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 5/9/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

public extension BaseUIView {
    
    // MARK: Constants & Types
    typealias ANIMATION_BLOCK = () -> Void
    
    static let ANIMATION_DURATION: TimeInterval = 0.3
    
    func animate(delay: TimeInterval = 0,_ block: @escaping ANIMATION_BLOCK) {
        UIView.animate(withDuration: BaseUIView.ANIMATION_DURATION, delay: 0, options: .beginFromCurrentState,
                       animations: block, completion: nil)
    }
}
