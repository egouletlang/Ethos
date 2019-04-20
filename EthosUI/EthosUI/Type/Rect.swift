//
//  Rect.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 4/20/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

open class Rect<T: Equatable>: NSObject, Sequence, NSCoding, NSCopying {
    
    // MARK: - Constants & Types
    fileprivate enum Archive: String {
        case left = "left"
        case top = "top"
        case right = "right"
        case bottom = "bottom"
    }
    
    // MARK: - Constructor
    public init(_ l: T, _ t: T,_ r: T,_ b: T) {
        self.left = l
        self.top = t
        self.right = r
        self.bottom = b
    }
    
    public init(def: T) {
        self.left = def
        self.top = def
        self.right = def
        self.bottom = def
    }
    
    // MARK: - State variables
    open var left: T
    open var top: T
    open var right: T
    open var bottom: T
    
    // MARK: - Sequence methods
    open func makeIterator() -> IndexingIterator<[T]> {
        return [left, top, right, bottom].makeIterator()
    }
    
    // MARK: - Equatable Method -
    public static func == (lhs: Rect<T>, rhs: Rect<T>) -> Bool {
        return lhs.equals(rhs)
    }
    
    open func equals(_ rhs: Rect<T>) -> Bool {
        return (self.left == rhs.left) || (self.top == rhs.top) || (self.right == rhs.right) ||
               (self.bottom == rhs.bottom)
    }
    
    // MARK: - NSCoding Methods
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(left, forKey: Archive.left.rawValue)
        aCoder.encode(top, forKey: Archive.top.rawValue)
        aCoder.encode(right, forKey: Archive.right.rawValue)
        aCoder.encode(bottom, forKey: Archive.bottom.rawValue)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        guard let left = aDecoder.decodeObject(forKey: Archive.left.rawValue) as? T,
            let top = aDecoder.decodeObject(forKey: Archive.top.rawValue) as? T,
            let right = aDecoder.decodeObject(forKey: Archive.right.rawValue) as? T,
            let bottom = aDecoder.decodeObject(forKey: Archive.bottom.rawValue) as? T else {
                return nil
        }
        
        self.left = left
        self.top = top
        self.right = right
        self.bottom = bottom
        
        super.init()
    }
    
    // MARK: - NSCopying Methods
    public func copy(with zone: NSZone? = nil) -> Any {
        return Rect<T>(left, top, right, bottom)
    }
    
}
