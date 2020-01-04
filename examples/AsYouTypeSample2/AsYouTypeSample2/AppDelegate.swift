//
//  AppDelegate.swift
//  AsYouTypeSample2
//
//  Created by Oskari Rauta on 04.01.20.
//  Copyright © 2020 Oskari Rauta. All rights reserved.
//

import UIKit
import CommonKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AppLocale {
    
    var regionCode: String = "fi_FI"
    /*
    lazy var window: UIWindow? = {
        var _window: UIWindow = UIWindow(frame: UIScreen.main.bounds)
        _window.backgroundColor = UIColor.systemFill
        _window.rootViewController = ViewController()
        _window.makeKeyAndVisible()
        return _window
    }()
*/
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

