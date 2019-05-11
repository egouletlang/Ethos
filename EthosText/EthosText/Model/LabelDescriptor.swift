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
    fileprivate enum Archive: String {
        case attr = "attr"
        case lines = "lines"
        case links = "links"
    }
    
    // MARK: - Builders & Constructors
    public override init() {}
    
    // MARK: - State variables
    open var attr: NSAttributedString?
    
    open var numberOfLines: Int = 0
    
    open var links: [String: NSRange] = [:]
    
    // MARK: - NSCoding Methods
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(attr, forKey: LabelDescriptor.Archive.attr.rawValue)
        aCoder.encode(numberOfLines, forKey: LabelDescriptor.Archive.lines.rawValue)
        aCoder.encode(links, forKey: LabelDescriptor.Archive.links.rawValue)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.attr = aDecoder.decodeObject(forKey: LabelDescriptor.Archive.attr.rawValue) as? NSAttributedString
        self.numberOfLines = aDecoder.decodeObject(forKey: LabelDescriptor.Archive.lines.rawValue) as? Int ?? 0
        self.links = aDecoder.decodeObject(forKey: LabelDescriptor.Archive.links.rawValue) as? [String: NSRange] ?? [:]
    }
    
    // MARK: - NSCopying Methods
    /**
     Create a deep copy
     */
    open func clone() -> LabelDescriptor {
        let ret = LabelDescriptor()
        ret.attr = self.attr
        ret.numberOfLines = self.numberOfLines
        ret.links = links
        return ret
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        return self.clone()
    }
    
}
