//
//  EthosUtilConfig.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

open class EthosUtilConfig: ModuleConfig {
    // MARK: - Constants & Types
    public typealias Delegate = EthosUtilConfigDelegate
    
    // MARK: - Singleton
    /**
     The EthosUtilConfig singleton pattern is used throughout the EthosUtil codebase
     */
    public static let shared = EthosUtilConfig()
    
    // MARK: - State
    /**
     This property casts a ModuleConfigDelegate to EthosUtilConfigDelegate
     */
    open weak var delegate: Delegate? {
        return self.moduleConfigDelegate as? Delegate
    }
    
    // MARK: - Required Overrides
    override open func getModuleBundle() -> Bundle? {
        return Bundle(for: EthosUtilConfig.self)
    }
    
    open override func getModuleBundlePath() -> String {
        return "Resources.bundle"
    }
    
    // MARK: - Injectable Configuration
    open var locale: Locale {
        return self.delegate?.getLocale?() ?? Locale.current
    }
}
