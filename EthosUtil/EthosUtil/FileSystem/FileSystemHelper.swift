//
//  FileSystemHelper.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

open class FileSystemHelper {
  
  public init() {}
  
  /**
   By default, the shared FileSystemHelper instance refers to the main app bundle
   */
  public static let shared = FileSystemHelper()
  
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
   - parameter resourceName: The file name, eg. in config.txt the resource name is "config"
   - parameter type: The file extension, eg. in config.txt the resource name is "txt"
   - returns: a URL for the requested file system resource if it exists
   */
  public func getBundleUrl(resourceName: String, type: String) -> URL? {
    if let url = self.bundle?.url(forResource: resourceName, withExtension: type) {
      return url
    }
    return self.bundle?.url(forResource: resourceName, withExtension: type)
  }
  
  /**
   This method returns a URL for a bundle resource.
   - important: the method uses the main bundle as a fallback should the instance bundle not contain the resource
   - parameter file: The file descriptor including the extension
   - returns: a URL for the requested file system resource if it exists
   */
  public func getBundleUrl(file: String) -> URL? {
    guard let (name, type) = file.getFileParts() else { return nil }
    return self.getBundleUrl(resourceName: name, type: type)
  }
  
  /**
   This method returns a String representing a bundle resource URL
   - important: the method uses the main bundle as a fallback should the instance bundle not contain the resource
   - parameter resourceName: The file name, eg. in config.txt the resource name is "config"
   - parameter type: The file extension, eg. in config.txt the resource name is "txt"
   - returns: The stringified URL for the resource file, or nil if the file could not be located.
   */
  public func getBundlePath(resourceName: String, type: String) -> String? {
    return self.getBundleUrl(resourceName: resourceName, type: type)?.absoluteString
  }
  
  /**
   This method returns a String representing a bundle resource URL
   - important: the method uses the main bundle as a fallback should the instance bundle not contain the resource
   - parameter file: The file descriptor including the extension
   - returns: The stringified URL for the resource file, or nil if the file could not be located.
   */
  public func getBundlePath(file: String) -> String? {
    guard let (name, type) = file.getFileParts() else { return nil }
    return self.getBundlePath(resourceName: name, type: type)
  }
  
  /**
   This method returns an FileSystemReference for a bundle resource.
   - important: the method uses the main bundle as a fallback should the instance bundle not contain the resource
   - parameter resourceName: The file name, eg. in config.txt the resource name is "config"
   - parameter type: The file extension, eg. in config.txt the resource name is "txt"
   - returns: a FileSystemReference instance for the requested resource in the bundle if it exists
   */
  public func getBundleFileSystemReference(resourceName: String, type: String) -> FileSystemReference? {
    if let url = self.getBundleUrl(resourceName: resourceName, type: type) {
      return FileSystemReference(fileUrl: url)
    }
    return nil
  }
  
  /**
   This method returns an FileSystemReference for a bundle resource.
   - important: the method uses the main bundle as a fallback should the instance bundle not contain the resource
   - parameter file: The file descriptor including the extension
   - returns: a FileSystemReference instance for the requested resource in the bundle if it exists
   */
  public func getBundleFileSystemReference(file: String) -> FileSystemReference? {
    guard let (name, type) = file.getFileParts() else { return nil }
    return self.getBundleFileSystemReference(resourceName: name, type: type)
  }
  
  // MARK: - File System Methods
  /**
   This method returns a URL a file system directory.
   - parameter name: The directory name
   - returns: a URL for the requested directory in the documentDirectory
   */
  public func getDirectoryUrl(name: String) -> URL? {
    guard var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
      return nil
    }
    
    url.appendPathComponent(name)
    
    do {
      try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
    } catch {
      
    }
    
    return url
  }
  
  /**
   This method returns a URL for a file system resource.
   - parameter resourceName: The file name, eg. in config.txt the resource name is "config"
   - parameter type: The file extension, eg. in config.txt the resource name is "txt"
   - returns: a URL for the requested file system resource in the documentDirectory
   */
  public func getFileSystemUrl(resourceName: String, type: String) -> URL? {
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
   - parameter file: The file descriptor including the extension
   - returns: a URL for the requested file system resource in the documentDirectory
   */
  public func getFileSystemUrl(file: String) -> URL? {
    guard let (name, type) = file.getFileParts() else { return nil }
    return self.getFileSystemUrl(resourceName: name, type: type)
  }
  
  /**
   This method returns a String representing a file system url
   - parameter resourceName: The file name, eg. in config.txt the resource name is "config"
   - parameter type: The file extension, eg. in config.txt the resource name is "txt"
   - returns: The stringified URL for the resource file, or nil if the file could not be located.
   */
  public func getFileSystemPath(resourceName: String, type: String) -> String? {
    return self.getFileSystemUrl(resourceName: resourceName, type: type)?.absoluteString
  }
  
  /**
   This method returns a String representing a file system url
   - parameter file: The file descriptor including the extension
   - returns: The stringified URL for the resource file, or nil if the file could not be located.
   */
  public func getFileSystemPath(file: String) -> String? {
    guard let (name, type) = file.getFileParts() else { return nil }
    return self.getFileSystemPath(resourceName: name, type: type)
  }
  
  /**
   This method returns a URL a file system directory.
   - parameter name: The directory name
   - returns: The FileSystemReference for the directory, or nil if the directory could not be located.
   */
  public func getDirectoryReference(name: String) -> FileSystemReference? {
    if let url = self.getDirectoryUrl(name: name) {
      return FileSystemReference(fileUrl: url)
    }
    return nil
  }
  
  /**
   This method returns a FileSystemReference representing a bundle resource
   - parameter resourceName: The file name, eg. in config.txt the resource name is "config"
   - parameter type: The file extension, eg. in config.txt the resource name is "txt"
   - returns: The FileSystemReference for the resource file, or nil if the file could not be located.
   */
  public func getFileSystemFileSystemReference(resourceName: String, type: String) -> FileSystemReference? {
    if let url = self.getFileSystemUrl(resourceName: resourceName, type: type) {
      return FileSystemReference(fileUrl: url)
    }
    return nil
  }
  
  /**
   This method returns a FileSystemReference representing a bundle resource
   - parameter file: The file descriptor including the extension
   - returns: The FileSystemReference for the resource file, or nil if the file could not be located.
   */
  public func getFileSystemFileSystemReference(file: String) -> FileSystemReference? {
    guard let (name, type) = file.getFileParts() else { return nil }
    return self.getFileSystemFileSystemReference(resourceName: name, type: type)
  }
  
  // MARK: - Helper Methods
  /**
   This method returns a URL representing a bundle resource
   - parameter bundle: target bundle
   - parameter resourceName: The file name, eg. in config.txt the resource name is "config"
   - parameter type: The file extension, eg. in config.txt the resource name is "txt"
   - returns: The full URL for the resource file, or nil if the file could not be located.
   */
  private func getBundleUrl(bundle: Bundle?, resourceName: String, type: String) -> URL? {
    return bundle?.url(forResource: resourceName, withExtension: type)
  }
  
  /**
   This method returns a String representing a bundle resource URL
   - parameter bundle: target bundle
   - parameter resourceName: The file name, eg. in config.txt the resource name is "config"
   - parameter type: The file extension, eg. in config.txt the resource name is "txt"
   - returns: The stringified URL for the resource file, or nil if the file could not be located.
   */
  private func getBundlePath(bundle: Bundle?, resourceName: String, type: String) -> String? {
    return self.getBundleUrl(bundle: bundle, resourceName: resourceName, type: type)?.absoluteString
  }
  
  /**
   This method returns a FileSystemReference representing a bundle resource
   - parameter bundle: target bundle
   - parameter resourceName: The file name, eg. in config.txt the resource name is "config"
   - parameter type: The file extension, eg. in config.txt the resource name is "txt"
   - returns: The FileSystemReference for the resource file, or nil if the file could not be located.
   */
  private func getBundleFileSystemReference(bundle: Bundle?, resourceName: String,
                                            type: String) -> FileSystemReference? {
    if let url = self.getBundleUrl(bundle: bundle, resourceName: resourceName, type: type) {
      return FileSystemReference(fileUrl: url)
    }
    return nil
  }
  
}
