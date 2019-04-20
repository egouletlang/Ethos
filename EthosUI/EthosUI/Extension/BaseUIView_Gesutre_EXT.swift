//
//  BaseUIView_EXT_Gesture.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 4/20/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

extension BaseUIView: UIGestureRecognizerDelegate {
    
    // MARK: Constants & Types
    fileprivate class LongPressHandler: UILongPressGestureRecognizer {
        var selector: String?
    }
    
    // MARK: - Gesture Methods
    public func addTap(_ view: UIView, selector: Selector) {
        let tapGesture = UITapGestureRecognizer(target: self, action: selector)
        tapGesture.numberOfTapsRequired = 1
        tapGesture.delegate = self
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGesture)
    }
    
    public func addLongPress(_ view: UIView, selector: String) {
        let longPressGesture = LongPressHandler(target: self,
                                                action: #selector(BaseUIView.selector_longPressDetected(_:)))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.selector = selector
        longPressGesture.delegate = self
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(longPressGesture)
    }
    
    // MARK: - UIGestureRecognizerDelegate Methods
    @objc func selector_longPressDetected(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.began {
            if let selector = (sender as? LongPressHandler)?.selector {
                performSelector(onMainThread: Selector(selector), with: self, waitUntilDone: false)
            }
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate Methods
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return (gestureRecognizer as? UITapGestureRecognizer == nil)
    }
    
}
