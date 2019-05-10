//
//  AppDelegate.swift
//  SampleApp
//
//  Created by Etienne Goulet-Lang on 5/10/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let root = TestUIViewController()
        root.view.backgroundColor = UIColor.red
        window?.addSubview(root.view)
        window?.rootViewController = root
        window?.makeKeyAndVisible()
        return true
    }

    
}

