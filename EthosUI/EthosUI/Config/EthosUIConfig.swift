//
//  EthosUIConfig.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 4/20/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import EthosUtil
import EthosImage

open class EthosUIConfig: ModuleConfig {
    
    // MARK: - Constants & Types
    public typealias Delegate = EthosUIConfigDelegate
    
    // MARK: - Singleton
    public static let shared = EthosUIConfig()
    
    // MARK: - State
    open weak var delegate: Delegate? {
        return self.moduleConfigDelegate as? Delegate
    }
    
    // MARK: - Required Overrides
    override open func getModuleBundle() -> Bundle? {
        return Bundle(for: EthosUIConfig.self)
    }
    
    open override func getModuleBundlePath() -> String {
        return "Resources.bundle"
    }
    
    public static var Refresh: UIImage? {
        return EthosUIConfig.shared.get(key: "refresh_image", def: EthosUIConfig.shared.getRefreshImage())
    }
    
    open func getRefreshImage() -> UIImage? {
        let image = self.delegate?.getRefreshImage?() ?? self.getImageFromBundle(resource: "down_arrow.png")
        return ImageHelper.addColorMask(img: image, color: getRefreshImageTint())
    }
    
    open func getRefreshImageTint() -> UIColor? {
        return self.delegate?.getRefreshImageTint?()
    }
    
    // MARK: - Injectable Configuration
    open var borderColor: UIColor {
        return self.delegate?.getBorderColor?() ?? UIColor(argb: 0x7B868C)
    }
    
    open var primaryColor: UIColor {
        return self.delegate?.getPrimaryColor?() ?? UIColor(argb: 0x1F426F)
    }
    
    open var tableviewBackgroundColor: UIColor {
        return UIColor(argb: 0xf8f8f8)
    }
    
    open var tableviewSectionBackgroundColor: UIColor {
        return UIColor(argb: 0xf8f8f8)
    }
    
}
