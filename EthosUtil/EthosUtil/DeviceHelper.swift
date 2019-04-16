//
//  DeviceHelper.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

/**
 The DeviceHelper class provides an interface to access basic device information
 */
open class DeviceHelper {
    
    // MARK: - App
    /**
     This property returns the name associated with the main bundle.
     */
    public static var appName: String? {
        return DeviceHelper.getFromMainBundle(key: "CFBundleName")
    }
    
    /**
     This property returns the major version associated with the main bundle
     */
    public static var appMajorVersion: String? {
        return DeviceHelper.getFromMainBundle(key: "CFBundleVersion")
    }
    
    /**
     This property returns the minor version associated with the main bundle
     */
    public static var appMinorVersion: String? {
        return DeviceHelper.getFromMainBundle(key: "CFBundleShortVersionString")
    }
    
    /**
     This property provides a convient way of displaying the current app version
     */
    public static var currentAppVersion: String {
        get  {
            guard let majorVersion = DeviceHelper.appMajorVersion,
                let minorVersion = DeviceHelper.appMinorVersion else {
                    return "no version"
            }
            return "\(majorVersion).\(minorVersion)"
        }
    }
    
    // MARK: - OS
    /**
     This static property returns the current operating system name
     */
    public static var osName: String {
        get {
            return UIDevice.current.systemName
        }
    }
    
    /**
     This static property returns the current operating system version
     */
    public static var osVersion: String {
        get {
            return UIDevice.current.systemVersion
        }
    }
    
    
    // MARK: - Device
    
    /**
     This property returns device name
     */
    public static var modelName: String {
        get {
            return UIDevice.current.model
        }
    }
    
    // MARK: - Helper Methods
    fileprivate static func getFromMainBundle<T>(key: String) -> T? {
        return FileSystemHelper.shared.bundle?.infoDictionary?.get(key) as? T
    }
    
}
