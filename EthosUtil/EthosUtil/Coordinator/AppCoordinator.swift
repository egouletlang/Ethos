//
//  AppCoordinator.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 8/6/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

/**
 The AppCoordinator handles the top level app state and navigation. Use this class to decouple the various activities -
 onboarding, tutorial, landing page, etc - in your app. Instantiate this class in the app delegate using a reference to
 the app's main window.
 */
@objc public protocol AppCoordinator: BaseCoordinator {
  
  init(_ window: UIWindow)
  
  var window: UIWindow { get set }
  
}
