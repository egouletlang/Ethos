//
//  EthosImageConfig.swift
//  EthosImage
//
//  Created by Etienne Goulet-Lang on 4/18/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import EthosUtil

open class EthosImageConfig: ModuleConfig {
    
    // MARK: - Constants & Types
    public typealias Delegate = EthosUtilConfigDelegate
    
    // MARK: - Singleton
    /**
     The EthosUtilConfig singleton pattern is used throughout the EthosUtil codebase
     */
    public static let shared = EthosImageConfig()
    
    // MARK: - State
    /**
     This property casts a ModuleConfigDelegate to EthosUtilConfigDelegate
     */
    open weak var delegate: Delegate? {
        return self.moduleConfigDelegate as? Delegate
    }
    
    // MARK: - Required Overrides
    override open func getModuleBundle() -> Bundle? {
        return Bundle(for: EthosImageConfig.self)
    }
    
    open override func getModuleBundlePath() -> String {
        return "Resources.bundle"
    }
    
    open override func configure() {
        super.configure()
        
        // When the app enters the background state, we should save the image cache state
        EventHelper.APP_BACKGROUND.subscribe(observer: self,
                                             selector: #selector(EthosImageConfig.selector_AppBackgrounded))
    }
    
    // MARK: - Selector
    @objc func selector_AppBackgrounded() {
        ImageHelper.shared.save()
    }
}
