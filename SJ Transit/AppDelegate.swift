//
//  AppDelegate.swift
//  SJ Transit
//
//  Created by Vashishtha Jogi on 11/18/15.
//  Copyright © 2015 Vashishtha Jogi. All rights reserved.
//

import UIKit
import SVProgressHUD
import Fabric
import Crashlytics


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    enum ShortcutIdentifier: String {
        case OpenMap
        case OpenFavorites
        case OpenRoutes
        
        init?(fullIdentifier: String) {
            guard let shortIdentifier = fullIdentifier.componentsSeparatedByString(".").last else {
                return nil
            }
            self.init(rawValue: shortIdentifier)
        }
    }
    
    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        SVProgressHUD.setForegroundColor(self.window?.rootViewController!.view.tintColor)
        
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem {
            self.handleShortcut(shortcutItem)
            return false
        }
        
        Fabric.with([Answers.self, Crashlytics.self])
        
        return true
    }

    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        completionHandler(self.handleShortcut(shortcutItem))
    }
    

    //MARK: - Force Touch shortcut methods
    private func handleShortcut(shortcutItem: UIApplicationShortcutItem) -> Bool {
        let shortcutType = shortcutItem.type
        guard let shortcutIdentifier = ShortcutIdentifier(fullIdentifier: shortcutType) else {
            return false
        }
        
        return self.selectTabBarItemForIdentifier(shortcutIdentifier)
    }
    
    private func selectTabBarItemForIdentifier(identifier: ShortcutIdentifier) -> Bool {
        guard let tabBarController = self.window?.rootViewController as? UITabBarController else {
            return false
        }
        
        switch (identifier) {
            case .OpenMap:
                tabBarController.selectedIndex = 0
                return true
            case .OpenFavorites:
                tabBarController.selectedIndex = 1
                return true
            case .OpenRoutes:
                tabBarController.selectedIndex = 2
                return true
        }
    }
}

