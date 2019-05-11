//
//  AppDelegate.swift
//  SampleApp
//
//  Created by Etienne Goulet-Lang on 5/10/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import UIKit
import EthosUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let view = BaseUIView(frame: CGRect.zero)
        view.createLayout()
        
//        let root = TestUIViewController()
//        window?.addSubview(root.view)
//        window?.rootViewController = root
//        window?.makeKeyAndVisible()
        return true
    }

    
}

