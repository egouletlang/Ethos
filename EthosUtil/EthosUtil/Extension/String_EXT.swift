//
//  String_EXT.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

public extension String {
    
    // MARK: - Access
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    // MARK: - Base64
    /**
     This method creates a base64 encoded string
     
     - returns: the encoded string
     */
    func base64Encoded() -> String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }
    
    /**
     This method decodes a base64 encoded string
     
     - returns: the decoded string
     */
    func base64Decoded() -> String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    /**
     This method separates the extension from the file path
     
     - returns: An tuple representing the (path, extension) or nil
     */
    func getFileParts() -> (String, String)? {
        let components = self.split(separator: ".")
        if components.count == 2 {
            return (String(components[0]), String(components[1]))
        }
        return nil
    }
    
    // MARK: - Helper Methods
    /**
     This method checks if the string starts with a particular substring
     
     - parameters:
     -  text: target substring
     
     - returns: true if the string starts with the `text` parameter
     */
    func startsWith(_ text: String) -> Bool {
        return self.hasPrefix(text)
    }
    
    /**
     This method checks if the string ends with a particular substring
     
     - parameters:
     -  text: target substring
     
     - returns: true if the string ends with the `text` parameter
     */
    func endsWith(_ text: String) -> Bool {
        return self.hasSuffix(text)
    }
    
    
}
