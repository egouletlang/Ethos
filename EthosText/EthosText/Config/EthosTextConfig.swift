//
//  EthosTextConfig.swift
//  EthosText
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import EthosUtil

open class EthosTextConfig: ModuleConfig {
    // MARK: - Constants & Types
    public typealias Delegate = EthosTextConfigDelegate
    
    // MARK: - Singleton
    /**
     The EthosUtilConfig singleton pattern is used throughout the EthosUtil codebase
     */
    public static let shared = EthosTextConfig()
    
    // MARK: - State
    /**
     This property casts a ModuleConfigDelegate to EthosUtilConfigDelegate
     */
    open weak var delegate: Delegate? {
        return self.moduleConfigDelegate as? Delegate
    }
    
    // MARK: - Required Overrides
    override open func getModuleBundle() -> Bundle? {
        return Bundle(for: EthosTextConfig.self)
    }
    
    open override func getModuleBundlePath() -> String {
        return "Resources.bundle"
    }
    
    // MARK: - Injectable Configuration
    open var regularFont: UIFont {
        return self.delegate?.getRegularFont?() ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)
    }
    
    open var boldFont : UIFont {
        return self.delegate?.getBoldFont?() ?? UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
    }
    
    open var italicFont : UIFont {
        return self.delegate?.getItalicFont?() ?? UIFont.italicSystemFont(ofSize: UIFont.systemFontSize)
    }
    
}
