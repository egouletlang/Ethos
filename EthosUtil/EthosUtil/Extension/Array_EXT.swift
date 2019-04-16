//
//  Array_EXT.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

public extension Array {
    
    /**
     This method provides a safe access to the array.
     
     The method returns the target element if the index is within the bounds, otherwise it returns nil
     
     - parameters:
        - index: target index
     
     - returns: the array element or nil
     */
    func get(_ index: Int) -> Element? {
        if index >= 0  && index < self.count {
            return self[index]
        } else {
            return nil
        }
    }
    
    /**
     This method creates an array slice, from [`start`, `end`)
     
     eg. arr.get(1, 5) -> [arr(1), arr(2), arr(3), arr(4)]
     
     This method will 'correct' the range provided using the following rules:
     1) if start < 0, set start to 0
     2) if end is less than start, increment end by count until it is not
     3) if end is greater than or equal to count, set end to count - 1
     
     With those rules, the method ensures that the range provided is valid and will not cause ruletime issues.
     Naturally, if the array is empty, any range provided will return an empty array
     
     - parameters:
         - start: start index, included in response
         - end: end index, excluded from response
     
     - returns: a new array instance with the target slice
     */
    func slice(start: Int, end: Int) -> [Element] {
        if self.count == 0 { return [] }
        
        var startIndex = start
        var endIndex = end
        
        if startIndex < 0 { startIndex = 0 }
        while endIndex < startIndex { endIndex += self.count }
        if endIndex >= self.count { endIndex = self.count - 1 }
        
        return Array(self[startIndex ..< endIndex])
    }
    
}
