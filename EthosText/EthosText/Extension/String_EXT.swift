//
//  String_EXT.swift
//  EthosText
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import EthosUtil

public extension String {
    
    var b: String {
        return self.addTag("b")
    }
    
    var i: String {
        return self.addTag("i")
    }
    
    var u: String {
        return self.addTag("u")
    }
    
    var tiny: String {
        return self.addTag("tiny")
    }
    
    var small: String {
        return self.addTag("small")
    }
    
    var large: String {
        return self.addTag("large")
    }
    
    var huge: String {
        return self.addTag("huge")
    }
    
    var left: String {
        return self.addTag("left")
    }
    
    var center: String {
        return self.addTag("center")
    }
    
    var right: String {
        return self.addTag("right")
    }
    
    /**
     This method wraps the current string with a tag
     
     - parameters:
        - tag: the tagname without the brackets
     
     - returns: tagged string
     */
    func addTag(_ tag: String) -> String {
        if self.isEmpty { return self }
        return String(format: "<%@>%@</%@>", arguments: [tag, self, tag])
    }
    
    /**
     This method wraps the current string with a color tag using a hex string
     
     - parameters:
        - color: a ARGB hex string, #AARRGGBB
     
     - returns: markup string
     */
    func addColor(_ color: String) -> String {
        if self.isEmpty { return self }
        return String(format: "<font color=\"%@\">%@</font>", arguments: [color, self])
    }
    
    /**
     This method wraps the current string with a color tag using a UIColor instance
     
     - parameters:
        - color: A UIColor
     
     - returns: markup string
     */
    func addColor(_ color: UIColor) -> String {
        if self.isEmpty { return self }
        return String(format: "<font color=\"%@\">%@</font>", arguments: [color.toString(), self])
    }
    
    /**
     This method wraps the current string with a link tag
     
     - parameters:
        - href: web or custom uri
     
     - returns: markup string
     */
    func addLink(_ href: String) -> String {
        if self.isEmpty { return self }
        return String(format: "<a href=\"%@\">%@</a>", arguments: [href, self])
    }

    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
}
