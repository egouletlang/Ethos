//
//  VariableHandle.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 4/30/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

public class VariableHandle<T> {
    
    public init(_ key: String,_ def: T) {
        self.key = key
        self.val = def
        self.def = def
    }
    
    public let key: String
    
    public var val: T
    
    public let def: T
    
    public func newInstance() -> VariableHandle<T> {
        return VariableHandle<T>(self.key, self.def)
    }
    
    public func encode(with aCoder: NSCoder) {
        if let val = self.val as? UIColor {
            aCoder.encode(val.toString(includeAlpha: true), forKey: self.key)
        } else if let val = self.val as? CGSize {
            aCoder.encode(NSValue(cgSize: val), forKey: self.key)
        }
        aCoder.encode(self.val, forKey: self.key)
    }
    
    public func decode(coder aDecoder: NSCoder) {
        if let hexString = aDecoder.decodeObject(forKey: self.key) as? String,
            let val = UIColor(hexString: hexString) as? T {
            self.val = val
        } else if let nsValue = aDecoder.decodeObject(forKey: self.key) as? NSValue,
            let val = nsValue.cgSizeValue as? T  {
            self.val = val
        } else if let val = aDecoder.decodeObject(forKey: self.key) as? T {
            self.val = val
        }
    }
    
    
}
