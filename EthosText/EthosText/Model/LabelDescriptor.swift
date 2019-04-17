//
//  LabelDescriptor.swift
//  EthosText
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

/**
 The LabelDescriptor class holds all the information required to display rich & functional text
 
 Supports:
 - NSAttributedStrings
 - Links
 
 */
open class LabelDescriptor: NSObject, NSCoding, NSCopying {
    
    // MARK: - Constants & Types
    fileprivate static let ATTR_ARCHIVE_KEY = "attr"
    fileprivate static let LINKS_ARCHIVE_KEY = "links"
    
    // MARK: - Builders & Constructors
    public override init() {}
    
    // MARK: - State variables
    /**
     This member holds a reference to the active NSAttributedString
     */
    open var attr: NSAttributedString?
    
    /**
     This member contains the links and their ranges in the NSAttributedString
     */
    open var links: [String: NSRange] = [:]
    
    
    // MARK: - NSCoding Methods
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(attr, forKey: LabelDescriptor.ATTR_ARCHIVE_KEY)
        aCoder.encode(links, forKey: LabelDescriptor.LINKS_ARCHIVE_KEY)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        guard let attr = aDecoder.decodeObject(forKey: LabelDescriptor.ATTR_ARCHIVE_KEY) as? NSAttributedString else {
            return nil
        }
        
        self.attr = attr
        
        if let links = aDecoder.decodeObject(forKey: LabelDescriptor.LINKS_ARCHIVE_KEY) as? [String: NSRange] {
            self.links = links
        }
    }
    
    // MARK: - NSCopying Methods
    /**
     Create a deep copy
     */
    open func clone() -> LabelDescriptor {
        let ret = LabelDescriptor()
        ret.attr = self.attr
        ret.links = links
        return ret
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        return self.clone()
    }
    
}
