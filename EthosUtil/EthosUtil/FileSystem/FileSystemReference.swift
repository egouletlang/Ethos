//
//  FileHandle.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

// swiftlint:disable identifier_name

/**
 This class provides a useful abstraction for dealing with file system resources.
 */
open class FileSystemReference {
  
  /**
   This constructor establishes the absolute file path for the FileSystemReference resource
   */
  public init(fileUrl: URL) {
    self.fileUrl = fileUrl
  }
  
  // MARK: - Path Methods
  /**
   This member stores the absolute file path for the FileSystemReference resource
   */
  public var fileUrl: URL
  
  /**
   This property returns a string version of the file path
   */
  public var filePath: String {
    return fileUrl.absoluteString
  }
  
  public func addPathComponent(component: String) {
    self.fileUrl.appendPathComponent(component)
  }
  
  public func addPathExtension(ext: String) {
    self.fileUrl.appendPathExtension(ext)
  }
  
  public func createNewFile(resourceName: String, type: String) -> FileSystemReference {
    let newUrl = self.directoryUrl
      .appendingPathComponent(resourceName)
      .appendingPathExtension(type)
    return FileSystemReference(fileUrl: newUrl)
  }
  
  /**
   This property returns true if the file path represents a file
   */
  public var isFile: Bool {
    return self.fileUrl.isFileURL
  }
  
  /**
   This property returns true if the file exists
   */
  public var fileExists: Bool {
    return FileManager.default.fileExists(atPath: self.filePath)
  }
  
  public var directoryUrl: URL {
    if self.fileUrl.hasDirectoryPath {
      return self.fileUrl
    }
    return self.fileUrl.deletingLastPathComponent()
  }
  
  public var directoryPath: String {
    return directoryUrl.absoluteString
  }
  
  public var directoryFileCount: Int {
    if self.isFile {
      return 0
    }
    return self.directoryFiles.count
  }
  
  public var directoryFiles: [FileSystemReference] {
    if self.isFile {
      return []
    }
    
    do {
      let urls = try FileManager.default.contentsOfDirectory(at: self.fileUrl, includingPropertiesForKeys: nil)
      return urls.compactMap { FileSystemReference(fileUrl: $0) }
    } catch {
      return []
    }
  }
  
  // MARK: - File Metadata Methods
  public var createdDate: Date? {
    do {
      let fileAttributes = try FileManager.default.attributesOfItem(atPath: self.filePath)
      return fileAttributes[FileAttributeKey.modificationDate] as? Date
    } catch {
      return nil
    }
  }
  
  // MARK: - File Methods
  /**
   This method creates the file if required
   */
  public func touch() {
    if !FileManager.default.fileExists(atPath: self.filePath) {
      FileManager.default.createFile(atPath: self.filePath, contents: nil, attributes: nil)
    }
  }
  
  /**
   This method reads the contents of the FileSystemReference resource
   - returns: Data object representing the contents of the file
   */
  public func read() throws -> Data {
    self.touch()
    return try Data(contentsOf: fileUrl)
  }
  
  /**
   This method replaces the content of the FileSystemReference resource
   
   - parameters:
   - data: the new content
   */
  @discardableResult
  public func overwrite(data: Data, useExceptions: Bool = true) throws -> Bool {
    self.touch()
    do {
      try data.write(to: self.fileUrl, options: .atomic)
      return true
    } catch let err {
      if useExceptions { throw err }
    }
    return false
  }
  
  /**
   This method deletes the FileSystemReference resource.
   */
  @discardableResult
  public func delete(useExceptions: Bool = true) throws -> Bool {
    do {
      try FileManager.default.removeItem(at: fileUrl)
      return true
    } catch let err {
      if useExceptions { throw err }
    }
    return false
  }
  
  // MARK: - Read Content
  /**
   This method tries to create a Data object using the FileSystemReference content
   
   - returns: A Data object representing the contents of the file
   */
  public func getData() -> Data? {
    return try? self.read()
  }
  
  /**
   This method tries to create a String object using the FileSystemReference content
   
   - parameters:
   - encoding: Specify which string encoding to use. The default is .utf8
   
   - returns: A String object representing the contents of the file
   */
  public func getString(encoding: String.Encoding = String.Encoding.utf8) -> String? {
    guard let data = getData() else { return nil }
    return String(data: data, encoding: encoding)
  }
  
  /**
   This method tries to create a UIImage object using the FileSystemReference content
   
   - returns: A UIImage object representing the contents of the file
   */
  public func getImage() -> UIImage? {
    guard let data = getData() else { return nil }
    return UIImage(data: data)
  }
  
  public func getObject<T: NSCoding>() -> T? {
    return self.getObjects().first
  }
  
  public func getObjects<T: NSCoding>() -> [T] {
    guard let data = getData(), let objs = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [T] else {
      return []
    }
    return objs
  }
  
  // MARK: - Write Content
  @discardableResult
  public func setObject<T: NSCoding>(obj: T?) -> Bool {
    if let o = obj {
      return self.setObjects(objs: [o])
    } else {
      return (try? self.delete(useExceptions: false)) ?? false
    }
  }
  
  @discardableResult
  public func setObjects<T: NSCoding>(objs: [T]) -> Bool {
    guard objs.count > 0 else {
      return (try? self.delete(useExceptions: false)) ?? false
    }
    
    var objData: Data!
    if #available(iOS 11.0, *) {
      guard let data = try? NSKeyedArchiver.archivedData(withRootObject: objs,
                                                         requiringSecureCoding: false) else { return false }
      objData = data
    } else {
      objData = NSKeyedArchiver.archivedData(withRootObject: objs)
    }
    
    return (try? self.overwrite(data: objData, useExceptions: false)) ?? false
  }
  
}
