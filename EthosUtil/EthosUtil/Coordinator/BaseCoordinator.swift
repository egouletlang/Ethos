//
//  BaseCoordinator.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 8/6/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

/**
 This protocol defines the backbone of the [coordinator pattern](https://en.wikipedia.org/wiki/Command_pattern).
 
 Here are several useful links that describe how to apply this pattern in iOS apps:
 - [hackingwithswift.com](https://www.hackingwithswift.com/articles/71/how-to-use-the-coordinator-pattern-in-ios-apps)
 - [raywenderlich.com](https://www.raywenderlich.com/158-coordinator-tutorial-for-ios-getting-started)
 
 In general, the coordinator pattern removes the navigation responsibility from the view controllers. This helps
 isolate business logic and improves view controller reusability.
 */

@objc public protocol BaseCoordinator {
  func start()
}
