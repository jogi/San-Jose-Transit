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
            guard let shortIdentifier = fullIdentifier.components(separatedBy: ".").last else {
                return nil
            }
            self.init(rawValue: shortIdentifier)
        }
    }
    
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setMinimumDismissTimeInterval(1.5)
        
        if let shortcutItem = launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            _ = self.handleShortcut(shortcutItem)
            return false
        }
        
        Fabric.with([Answers.self, Crashlytics.self])
        
        self.checkForUpdate()
        Utilities.cleanupOldFiles()
        Favorite.createFavoritesIfRequred()
        
        return true
    }

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(self.handleShortcut(shortcutItem))
    }
    

    //MARK: - Force Touch shortcut methods
    fileprivate func handleShortcut(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        let shortcutType = shortcutItem.type
        guard let shortcutIdentifier = ShortcutIdentifier(fullIdentifier: shortcutType) else {
            return false
        }
        
        return self.selectTabBarItemForIdentifier(shortcutIdentifier)
    }
    
    fileprivate func selectTabBarItemForIdentifier(_ identifier: ShortcutIdentifier) -> Bool {
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
    
    fileprivate func checkForUpdate() {
        if Utilities.isScheduleEmpty() == false {
            Update.checkForUpdates { (result) in
                switch (result) {
                case .success(let update):
                    DispatchQueue.main.async {
                        if let window = self.window, let viewController = window.rootViewController {
                            if update.isNewerVersion() == true {
                                update.presentUpdateAlert(on: viewController) {
                                    update.downloadAndUnzip(nil)
                                }
                            }
                        }
                    }
                case .failure(_):
                    break
                }
            }
        }
    }
}

