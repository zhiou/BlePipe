//
//  AppDelegate.swift
//  BPDemo
//
//  Created by zhiou on 2021/8/9.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        if let keyWindow = window {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let navigationController = storyboard.instantiateInitialViewController()
            keyWindow.rootViewController = navigationController
            keyWindow.makeKeyAndVisible()
        }
        return true
    }

}

