//
//  LinkedList.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

/**
 The LinkedList class creates a doubly-linked list data structure. The structure grows by appending to the tail node,
 meaning that the head node is the oldest and the tail is the newest.
 
 - important: Other linked list solutions in the Ethos project should inherit from this class to maintain a consistent
 interface
 
 - TODO: Add NSCoding implementation and File System functionality
 
 ## LinkedListNode Methods
 - `append(node: LinkedListNode<T>, ...)`
 - `remove(node: LinkedListNode<T>, ...)`
 - `getAt(index: Int, ...) -> LinkedListNode<T>?`
 - `getNodeWithValue(value: T, ...) -> LinkedListNode<T>?`
 - `clear(...)`
 
 ## Data Methods
 - `append(value: T, ...)`
 - `remove(value: T, ...) -> Bool`
 - `getAt(index: Int, ...) -> T?`
 - `pop(...) -> T?`
 
 By default, this linked list is not thread safe. Set the `synchronize` parameter to true in any one of these methods to
 lock the cache and allow a single thread to access it at a time.
 */
public class LinkedList<T: Equatable & Comparable> {
    
    // MARK: - State Variables
    /**
     This member represents the oldest node in the list
     */
    fileprivate var head: LinkedListNode<T>?
    
    /**
     This member represents the newest node in the list
     */
    fileprivate var tail: LinkedListNode<T>?
    
    /**
     This member tracks the number of nodes in the list
     */
    fileprivate var count: Int = 0
    
    /**
     This member is used to synchronize any cache operation where the `synchronize` parameter set to true
     */
    let lock = Lock()
    
    /**
     This property returns true if the number of nodes in the list is 0
     */
    open var isEmpty: Bool {
        return count == 0
    }
    
    /**
     This property returns a reference to the oldest link list element
     */
    open var oldest: T? {
        return head?.value
    }
    
    /**
     This property returns a reference to the newest link list element
     */
    open var newest: T? {
        return tail?.value
    }
    
    /**
     This method returns the current number of nodes in the linked list
     */
    open func length() -> Int {
        return count
    }
    
    // MARK: - Operations
    /**
     This method attaches a node to the tail of the linked list. This will create a new `tail` and change the `newest`
     property.
     
     - parameters:
         - node: A node instance you want to add to the list.
         - synchronize: Set to true to make this call thread-safe. defaults to False.
     */
    open func append(node: LinkedListNode<T>, synchronize: Bool = false) {
        if (synchronize) {
            self.lock.synchronize { [weak self] in
                self?.append(node: node, synchronize: false)
            }
            return
        }
        
        // Logic:
        // ------
        // if the current tail is not nil.
        //      1) set the new node `prev` reference to the current tail
        //      2) set the current tail `next` reference to the new node
        //      3) new node becomes the current tail
        // else
        //      1) new node becomes the current head
        //      2) new ndoe becomes the current tail
        //
        // Increment count
        
        if let tailNode = tail {
            node.prev = tailNode
            tailNode.next = node
        } else {
            head = node
        }
        tail = node
        count += 1
    }
    
    /**
     This method attaches a node to the tail of the linked list. This will create a new `tail` and change the `newest`
     property.
     
     - parameters:
         - node: A node instance you want to remove from the list.
         - synchronize: Set to true to make this call thread-safe. defaults to False.
     */
    open func remove(node: LinkedListNode<T>, synchronize: Bool = false) {
        if (synchronize) {
            self.lock.synchronize { [weak self] in
                self?.remove(node: node, synchronize: false)
            }
            return
        }
        
        // Logic:
        // ------
        // The node contains references to the previous and next nodes in the chain.
        //
        // if the previous node is not nil
        //      1) set the `next` reference on the previous node to the next node
        // else
        //      1) set the next node to the new head
        //
        // if the next node is not nil
        //      1) set the `prev` reference on the next node to the previous node
        // else
        //      1) set the previous node to the tail
        //
        // Decrement count
        //
        // corner cases:
        //  - removing the last node.
        //    prev and next should be nil, the optional reference assignment won't occur and the head and tail
        //    references will be set to nil
        
        let prev = node.prev
        let next = node.next
        
        prev?.next = next
        if prev == nil {
            head = next
        }
        
        next?.prev = prev
        if next == nil {
            tail = prev
        }
        
        // clean up the reference to avoid hanging pointers
        node.prev = nil
        node.next = nil
        count -= 1
    }
    
    /**
     This method gets the node at nth index from the head, if it exists. The node is passed by reference
     
     - parameters:
         - index: index for the target node
         - synchronize: Set to true to make this call thread-safe. defaults to False.
     */
    open func getAt(index: Int, synchronize: Bool = false) -> LinkedListNode<T>? {
        if (synchronize) {
            var ret: LinkedListNode<T>?
            self.lock.synchronize { [weak self] in
                ret = self?.getAt(index: index, synchronize: false)
            }
            return ret
        }
        
        if index >= 0 {
            var node = head
            var i = index
            while node != nil {
                if i == 0 { return node }
                i -= 1
                node = node?.next
            }
        }
        return nil
    }
    
    /**
     This method gets the first node from the head with a certain value. The node is passed by reference
     
     - parameters:
         - value: value of the target node
         - synchronize: Set to true to make this call thread-safe. defaults to False.
     */
    open func getNodeWithValue(value: T, synchronize: Bool = false) -> LinkedListNode<T>? {
        if (synchronize) {
            var ret: LinkedListNode<T>?
            self.lock.synchronize { [weak self] in
                ret = self?.getNodeWithValue(value: value, synchronize: false)
            }
            return ret
        }
        
        var node = head
        while node != nil {
            if value == node?.value {
                return node
            }
            node = node?.next
        }
        return nil
    }
    
    /**
     This method returns an ordered list of all nodes in the linked list starting from the head
     
     - parameters:
        - synchronize: Set to true to make this call thread-safe. defaults to False.
     
     - returns: A list of LinkedListNode instances
     */
    open func all(synchronize: Bool = false) -> [LinkedListNode<T>] {
        var ret = [LinkedListNode<T>]()
        
        if (synchronize) {
            self.lock.synchronize { [weak self] in
                guard let strong = self else { return }
                ret = strong.all(synchronize: false)
            }
            return ret
        }
        
        var currNode = self.head
        while (currNode != nil) {
            ret.append(currNode!)
            currNode = currNode!.next
        }
        
        return ret
    }
    
    // MARK: - Data methods
    /**
     This method creates a new LinkedListNode for the value provide and adds it to the LinkedList
     
     - Parameters:
         - value: The value will be added to the end of the LinkedList
         - synchronize: Set to true to make this call thread-safe. defaults to False.
     */
    open func append(value: T, synchronize: Bool = false) {
        self.append(node: LinkedListNode(value: value), synchronize: synchronize)
    }
    
    /**
     This method finds the first node with a certain value and removes it from the collection.
     
     - Parameters:
         - value: target value
         - synchronize: Set to true to make this call thread-safe. defaults to False.
     
     - returns: `true` if a node was removed and `false` if the node was not part of the collection.
     */
    open func remove(value: T, synchronize: Bool = false) -> Bool {
        if (synchronize) {
            var ret = false
            self.lock.synchronize { [weak self] in
                ret = self?.remove(value: value, synchronize: false) ?? false
            }
            return ret
        }
        
        if let node = self.getNodeWithValue(value: value) {
            remove(node: node)
            return true
        }
        return false
    }
    
    /**
     This method gets the value of the node at nth index from the head, if it exists.
     
     - parameters:
         - index: index for the target node
         - synchronize: Set to true to make this call thread-safe. defaults to False.
     */
    open func getAt(index: Int, synchronize: Bool = false) -> T? {
        return self.getAt(index: index, synchronize: synchronize)?.value
    }
    
    /**
     This method removes either the head or the tail based on the value of the `fromEnd` parameter.
     
     - Parameters:
         - fromEnd: Set to true to remove the tail node (the newest node in the collection) or the head node (the oldest
                    node in the collection). Defaults to false
         - synchronize: Set to true to make this call thread-safe. defaults to False.
     
     - Returns: The value of the target node, if it exists
     */
    open func pop(fromEnd: Bool = false, synchronize: Bool = false) -> T? {
        if let node = fromEnd ? tail : head {
            remove(node: node, synchronize: synchronize)
            return node.value
        }
        return nil
    }
    
    /**
     This method removes all nodes in the linked list
     
     - Parameters:
        - synchronize: Set to true to make this call thread-safe. defaults to False.
     */
    open func clear(synchronize: Bool = false) {
        if (synchronize) {
            self.lock.synchronize { [weak self] in
                self?.clear(synchronize: false)
            }
            return
        }
        
        var node = head
        var next = head
        while node != nil {
            next = node?.next
            node?.prev = nil
            node?.next = nil
            node = next
        }
        head = nil
        tail = nil
        count = 0
    }
    
    /**
     This method returns an ordered list of all value in the linked list starting from the head
     
     - parameters:
        - synchronize: Set to true to make this call thread-safe. defaults to False.
     
     - returns: A list of LinkedListNode instances
     */
    open func all(synchronize: Bool = false) -> [T] {
        return self.all(synchronize: synchronize).compactMap() { $0.value }
    }
    
}
