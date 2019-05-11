//
//  ModuleConfig.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

/**
 The ModuleConfig class offers a easy way to centralizes all data injection for a module. Resources typically have a
 default value, but can be overridden using a delegate
 */
open class ModuleConfig {
    
    // MARK: - Constants & Types
    fileprivate static let DEFAULT_MODULE_BUNDLE_PATH = "__RESERVED__.default_module_bundle_path"
    
    // MARK: - Builders & Constructors
    public init() {
        assert(getModuleBundle() != nil, "You must set the module bundle by overriding getModuleBundle(...)")
        assert(getModuleBundlePath() != ModuleConfig.DEFAULT_MODULE_BUNDLE_PATH,
               "You must set the module bundle path by overriding getModuleBundlePath(...)")
        
        if let bundleURL = getModuleBundle()?.resourceURL?.appendingPathComponent(getModuleBundlePath()) {
            fileSystemHelper = FileSystemHelper()
            fileSystemHelper?.bundle = Bundle(url: bundleURL)
        }
    }
    
    // MARK: - Singleton & Delegate
    /**
     This member holds a reference to the ModuleConfigDelegate instance. Set this delegate to override the module
     default configuration values
     */
    open weak var moduleConfigDelegate: ModuleConfigDelegate?
    
    // MARK: - State variables
    /**
     This member stores a reference to a FileSystemHelper with a reference to the module bundle
     */
    private var fileSystemHelper: FileSystemHelper?
    
    private var cache = [String: Any]()
    
    public func get<T>(key: String, def: T?) -> T? {
        return self.cache.get(key) { return def } as? T
    }
    
    // MARK: - Helper Methods
    /**
     This method gets an image from the module bundle
     */
    open func getImageFromBundle(resource: String) -> UIImage? {
        guard let (resourceName, type) = resource.getFileParts() else { return nil }
        let fh = fileSystemHelper?.getBundleFileHandle(resourceName: resourceName, type: type)
        return fh?.getImage()
    }
 
    // MARK: - “Abstract” Methods (Override these)
    /**
     This method returns a reference to the module bundle
     */
    open func getModuleBundle() -> Bundle? {
        return nil
    }
    
    /**
     This method returns a path to the resources inside the module bundle
     */
    open func getModuleBundlePath() -> String {
        return ModuleConfig.DEFAULT_MODULE_BUNDLE_PATH
    }
    
    /**
     Use this method to setup the internal configuration of the module. The module can assume that the top level project
     will call this method after it has setup it data injection logic.
     */
    open func configure() {}
}
