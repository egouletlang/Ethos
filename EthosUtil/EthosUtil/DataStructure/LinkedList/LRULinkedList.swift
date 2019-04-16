//
//  LRULinkedList.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

/**
 The LRULinkedList class creates a linked list that moves elements around to keep the elements in least recently used
 order.
 
 ## Characteristics
 1) head is the lru node
 2) tail is the mru node
 3) `prev` references are closer to the head, `next` references are closer to the tail
 4) traversal should start from the the head and go to the tail
 
 
 By default, this cache is not thread safe. Set the `synchronize` parameter to true in any one of these methods to
 lock the cache and allow a single thread to access it at a time.
 */
public class LRULinkedList<T: Equatable & Comparable>: LinkedList<T> {
    
    /**
     The LRULinkedList class overrides this method. This method first checks if the node is present in the list. If it
     is, the method moves the node to the tail making it the MRU element. Otherwise the behavior is the same.
     
     - parameters:
         - node: A node instance you want to add to the list.
         - synchronize: Set to true to make this call thread-safe. defaults to False.
     */
    open override func append(node: LinkedListNode<T>, synchronize: Bool = false) {
        if (synchronize) {
            self.lock.synchronize { [weak self] in
                self?.append(node: node, synchronize: false)
            }
            return
        }
        
        var newNode = node
        if let currNode = self.getNodeWithValue(value: node.value) {
            remove(node: currNode)
            newNode = currNode
        }
        super.append(node: newNode)
    }
    
    /**
     The LRULinkedList class overrides this method. In addition getting the node at nth index from the head, the method
     moves the node to the tail making it the MRU element.
     
     - parameters:
         - index: index for the target node
         - synchronize: Set to true to make this call thread-safe. defaults to False.
     */
    open override func getAt(index: Int, synchronize: Bool = false) -> LinkedListNode<T>? {
        if (synchronize) {
            var ret: LinkedListNode<T>?
            self.lock.synchronize { [weak self] in
                ret = self?.getAt(index: index, synchronize: false)
            }
            return ret
        }
        
        if let node: LinkedListNode<T> = super.getAt(index: index) {
            remove(node: node)
            self.append(node: node)
            return node
        }
        
        return nil
    }
    
}
