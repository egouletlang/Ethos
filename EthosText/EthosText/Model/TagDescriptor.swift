//
//  TagDescriptor.swift
//  EthosText
//
//  Created by Etienne Goulet-Lang on 4/17/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

open class TagDescriptor {
    
    public enum Tag: String {
        case Bold = "b"
        case Italic = "i"
        case Underline = "u"
        case Tiny = "tiny"
        case Small = "small"
        case Large = "large"
        case Huge = "huge"
        case Left = "left"
        case Center = "center"
        case Right = "right"
        case Link = "a"
        case Font = "font"
        
        public static func toTag(str: String) -> (Tag, Bool)? {
            if str.startsWith("/") {
                guard let (tag, _) = Tag.toTag(str: str.substring(from: 1)) else {
                    return nil
                }
                return (tag, false)
            }
            
            if str.startsWith(Bold.rawValue) { return (Bold, true) }
            if str.startsWith(Italic.rawValue) { return (Italic, true) }
            if str.startsWith(Underline.rawValue) { return (Underline, true) }
            if str.startsWith(Tiny.rawValue) { return (Tiny, true) }
            if str.startsWith(Small.rawValue) { return (Small, true) }
            if str.startsWith(Large.rawValue) { return (Large, true) }
            if str.startsWith(Huge.rawValue) { return (Huge, true) }
            if str.startsWith(Left.rawValue) { return (Left, true) }
            if str.startsWith(Center.rawValue) { return (Center, true) }
            if str.startsWith(Right.rawValue) { return (Right, true) }
            if str.startsWith(Link.rawValue) { return (Link, true) }
            if str.startsWith(Font.rawValue) { return (Font, true) }
            
            return nil
        }
    
    }
    
    public init?(str: String, index: Int) {
        guard let (tag, isOpen) = Tag.toTag(str: str) else {
            return nil
        }
        
        self.index = index
        self.rawTag = str
        self.tag = tag
        self.isOpen = isOpen
    }
    
    open var index: Int
    
    open var rawTag: String
    
    open var tag: Tag
    
    open var isOpen: Bool
    
    open var color: UIColor? {
        let components = rawTag.split(separator: "\"")
        guard isOpen, components.count > 1 else {
            return nil
        }
        return UIColor(hexString: String(components[1]))
    }
    
    open var link: String? {
        let components = rawTag.split(separator: "\"")
        guard isOpen, components.count > 1 else {
            return nil
        }
        return String(components[1])
    }
    
}
