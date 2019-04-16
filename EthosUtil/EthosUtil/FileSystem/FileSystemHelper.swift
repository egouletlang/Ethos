//
//  FileSystemHelper.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

open class FileSystemHelper {
    
    // MARK: - Builders & Constructors
    public init() {}
    
    // MARK: - Singleton & Delegate
    /**
     By default, the shared FileSystemHelper instance refers to the main app bundle
     */
    public static let shared = FileSystemHelper()
    
    // MARK: - State Variable
    /**
     This member refers to the Bundle used to find bundle files
     */
    open var bundle: Bundle? = Bundle.main
    
    /**
     This member indicates whether the resource bundle has a flat hierarchy
     */
    open var isFlatBundle = true
    
    // MARK: - Bundle Methods
    /**
     This method returns a URL for a bundle resource.
     
     - important: the method uses the main bundle as a fallback should the instance bundle not contain the resource
     
     - parameters:
         - resourceName: The file name, eg. in config.txt the resource name is "config"
         - type: The file extension, eg. in config.txt the resource name is "txt"
     
     - returns: a URL for the requested file system resource if it exists
     */
    open func getBundleUrl(resourceName: String, type: String) -> URL? {
        if let url = self.bundle?.url(forResource: resourceName, withExtension: type) {
            return url
        }
        return self.bundle?.url(forResource: resourceName, withExtension: type)
    }
    
    /**
     This method returns a URL for a bundle resource.
     
     - important: the method uses the main bundle as a fallback should the instance bundle not contain the resource
     
     - parameters:
         - file: The file descriptor including the extension
     
     - returns: a URL for the requested file system resource if it exists
     */
    open func getBundleUrl(file: String) -> URL? {
        guard let (name, type) = file.getFileParts() else { return nil }
        return self.getBundleUrl(resourceName: name, type: type)
    }
    
    /**
     This method returns a String representing a bundle resource URL
     
     - important: the method uses the main bundle as a fallback should the instance bundle not contain the resource
     
     - parameters:
         - resourceName: The file name, eg. in config.txt the resource name is "config"
         - type: The file extension, eg. in config.txt the resource name is "txt"
     
     - returns: The stringified URL for the resource file, or nil if the file could not be located.
     */
    open func getBundlePath(resourceName: String, type: String) -> String? {
        return self.getBundleUrl(resourceName: resourceName, type: type)?.absoluteString
    }
    
    /**
     This method returns a String representing a bundle resource URL
     
     - important: the method uses the main bundle as a fallback should the instance bundle not contain the resource
     
     - parameters:
        - file: The file descriptor including the extension
     
     - returns: The stringified URL for the resource file, or nil if the file could not be located.
     */
    open func getBundlePath(file: String) -> String? {
        guard let (name, type) = file.getFileParts() else { return nil }
        return self.getBundlePath(resourceName: name, type: type)
    }
    
    /**
     This method returns an FileHandle for a bundle resource.
     
     - important: the method uses the main bundle as a fallback should the instance bundle not contain the resource
     
     - parameters:
         - resourceName: The file name, eg. in config.txt the resource name is "config"
         - type: The file extension, eg. in config.txt the resource name is "txt"
     
     - returns: a FileHandle instance for the requested resource in the bundle if it exists
     */
    open func getBundleFileHandle(resourceName: String, type: String) -> FileHandle? {
        if let url = self.getBundleUrl(resourceName: resourceName, type: type) {
            return FileHandle(fileUrl: url)
        }
        return nil
    }
    
    /**
     This method returns an FileHandle for a bundle resource.
     
     - important: the method uses the main bundle as a fallback should the instance bundle not contain the resource
     
     - parameters:
        - file: The file descriptor including the extension
     
     - returns: a FileHandle instance for the requested resource in the bundle if it exists
     */
    open func getBundleFileHandle(file: String) -> FileHandle? {
        guard let (name, type) = file.getFileParts() else { return nil }
        return self.getBundleFileHandle(resourceName: name, type: type)
    }
    
    // MARK: - File System Methods
    /**
     This method returns a URL for a file system resource.
     
     - parameters:
         - resourceName: The file name, eg. in config.txt the resource name is "config"
         - type: The file extension, eg. in config.txt the resource name is "txt"
     
     - returns: a URL for the requested file system resource in the documentDirectory
     */
    open func getFileSystemUrl(resourceName: String, type: String) -> URL? {
        guard var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } catch {
            
        }
        url.appendPathComponent(resourceName)
        url.appendPathExtension(type)
        return url
    }
    
    /**
     This method returns a URL for a file system resource.
     
     - parameters:
        - file: The file descriptor including the extension
     
     - returns: a URL for the requested file system resource in the documentDirectory
     */
    open func getFileSystemUrl(file: String) -> URL? {
        guard let (name, type) = file.getFileParts() else { return nil }
        return self.getFileSystemUrl(resourceName: name, type: type)
    }
    
    /**
     This method returns a String representing a file system url
     
     - parameters:
         - resourceName: The file name, eg. in config.txt the resource name is "config"
         - type: The file extension, eg. in config.txt the resource name is "txt"
     
     - returns: The stringified URL for the resource file, or nil if the file could not be located.
     */
    open func getFileSystemPath(resourceName: String, type: String) -> String? {
        return self.getFileSystemUrl(resourceName: resourceName, type: type)?.absoluteString
    }
    
    /**
     This method returns a String representing a file system url
     
     - parameters:
        - file: The file descriptor including the extension
     
     - returns: The stringified URL for the resource file, or nil if the file could not be located.
     */
    open func getFileSystemPath(file: String) -> String? {
        guard let (name, type) = file.getFileParts() else { return nil }
        return self.getFileSystemPath(resourceName: name, type: type)
    }
    
    /**
     This method returns a FileHandle representing a bundle resource
     
     - parameters:
         - resourceName: The file name, eg. in config.txt the resource name is "config"
         - type: The file extension, eg. in config.txt the resource name is "txt"
     
     - returns: The FileHandle for the resource file, or nil if the file could not be located.
     */
    open func getFileSystemFileHandle(resourceName: String, type: String) -> FileHandle? {
        if let url = self.getFileSystemUrl(resourceName: resourceName, type: type) {
            return FileHandle(fileUrl: url)
        }
        return nil
    }
    
    /**
     This method returns a FileHandle representing a bundle resource
     
     - parameters:
        - file: The file descriptor including the extension
     
     - returns: The FileHandle for the resource file, or nil if the file could not be located.
     */
    open func getFileSystemFileHandle(file: String) -> FileHandle? {
        guard let (name, type) = file.getFileParts() else { return nil }
        return self.getFileSystemFileHandle(resourceName: name, type: type)
    }
    
    // MARK: - Helper Methods
    /**
     This method returns a URL representing a bundle resource
     
     - parameters:
     - bundle: target bundle
     - resourceName: The file name, eg. in config.txt the resource name is "config"
     - type: The file extension, eg. in config.txt the resource name is "txt"
     
     - returns: The full URL for the resource file, or nil if the file could not be located.
     */
    fileprivate func getBundleUrl(bundle: Bundle?, resourceName: String, type: String) -> URL? {
        return bundle?.url(forResource: resourceName, withExtension: type)
    }
    
    /**
     This method returns a String representing a bundle resource URL
     
     - parameters:
     - bundle: target bundle
     - resourceName: The file name, eg. in config.txt the resource name is "config"
     - type: The file extension, eg. in config.txt the resource name is "txt"
     
     - returns: The stringified URL for the resource file, or nil if the file could not be located.
     */
    fileprivate func getBundlePath(bundle: Bundle?, resourceName: String, type: String) -> String? {
        return self.getBundleUrl(bundle: bundle, resourceName: resourceName, type: type)?.absoluteString
    }
    
    /**
     This method returns a FileHandle representing a bundle resource
     
     - parameters:
     - bundle: target bundle
     - resourceName: The file name, eg. in config.txt the resource name is "config"
     - type: The file extension, eg. in config.txt the resource name is "txt"
     
     - returns: The FileHandle for the resource file, or nil if the file could not be located.
     */
    fileprivate func getBundleFileHandle(bundle: Bundle?, resourceName: String, type: String) -> FileHandle? {
        if let url = self.getBundleUrl(bundle: bundle, resourceName: resourceName, type: type) {
            return FileHandle(fileUrl: url)
        }
        return nil
    }
    
}
