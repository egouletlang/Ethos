//
//  UICoordinator.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 8/6/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

/**
 The UICoordinator handles the navigation between related `UIViewControllers`
 */
@objc public protocol UICoordinator: BaseCoordinator {
  
  var childCoordinators: [UICoordinator] { get set }
  
  var navigationController: UINavigationController { get set }
  
  func start()
}
