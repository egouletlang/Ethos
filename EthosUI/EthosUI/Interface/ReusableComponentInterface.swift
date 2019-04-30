//
//  ReusableComponentInterface.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 4/20/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

@objc
public protocol ReusableComponentInterface {
    @objc optional func prepareForReuse()
    
    // On Screen
    @objc optional func willAppear(first: Bool)
    @objc optional func onScreen(first: Bool)
    @objc optional func didAppear(first: Bool)
    
    // Off Screen
    @objc optional func willDisappear(first: Bool)
    @objc optional func offScreen(first: Bool)
    @objc optional func didDisappear(first: Bool)
    
}
