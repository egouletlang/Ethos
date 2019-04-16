//
//  FileHandle.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

/**
 This class provides a useful abstraction for dealing with file system resources.
 */
open class FileHandle {
    
    // MARK: - Builders & Constructors
    /**
     This constructor establishes the absolute file path for the FileHandle resource
     */
    public init(fileUrl: URL) {
        self.fileUrl = fileUrl
    }
    
    // MARK: - State Variables
    /**
     This member stores the absolute file path for the FileHandle resource
     */
    public let fileUrl: URL
    
    /**
     This property returns a string version of the file path
     */
    open var filePath: String {
        return fileUrl.absoluteString
    }
    
    /**
     This property returns true if the file path represents a file
     */
    open var isFile: Bool {
        return FileManager.default.isReadableFile(atPath: self.filePath)
    }
    
    /**
     This property returns true if the file exists
     */
    open var fileExists: Bool {
        return FileManager.default.fileExists(atPath: self.filePath)
    }
    
    // MARK: - File Methods
    /**
     This method creates the file if required
     */
    open func touch() {
        if !FileManager.default.fileExists(atPath: self.filePath) {
            FileManager.default.createFile(atPath: self.filePath, contents: nil, attributes: nil)
        }
    }
    
    /**
     This method reads the contents of the FileHandle resource
     - returns: Data object representing the contents of the file
     */
    open func read() throws -> Data {
        self.touch()
        return try Data(contentsOf: fileUrl)
    }
    
    /**
     This method replaces the content of the FileHandle resource
     
     - parameters:
        - data: the new content
     */
    open func overwrite(data: Data) throws {
        self.touch()
        try data.write(to: self.fileUrl, options: .atomic)
    }
    
    /**
     This method deletes the FileHandle resource.
     */
    open func delete() throws {
        try FileManager.default.removeItem(at: fileUrl)
    }
    
    // MARK: - Content Methods
    /**
     This method tries to create a Data object using the FileHandle content
     
     - returns: A Data object representing the contents of the file
     */
    open func getData() -> Data? {
        do {
            return try self.read()
        } catch {
            return nil
        }
    }
    
    /**
     This method tries to create a String object using the FileHandle content
     
     - parameters:
        - encoding: Specify which string encoding to use. The default is .utf8
     
     - returns: A String object representing the contents of the file
     */
    open func getString(encoding: String.Encoding = String.Encoding.utf8) -> String? {
        do {
            let data = try self.read()
            return String(data: data, encoding: encoding)
        } catch {
            return nil
        }
    }
    
    /**
     This method tries to create a UIImage object using the FileHandle content
     
     - returns: A UIImage object representing the contents of the file
     */
    open func getImage() -> UIImage? {
        do {
            let data = try self.read()
            return UIImage(data: data)
        } catch {
            return nil
        }
    }
    
    
}
