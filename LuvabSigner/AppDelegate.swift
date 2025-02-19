//
//  AppDelegate.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 9/17/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    lazy var applicationCoordinator: ApplicationCoordinator = {
        ApplicationCoordinator(window: window)
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Thread.sleep(forTimeInterval: 0.5)
        
        application.registerForRemoteNotifications()
        
        applicationCoordinator.start(appDelegate: self)
        
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.badge, .alert , .sound]) { (greanted, error) in
                if greanted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                    
                }
            }
        } else {
            
            let setting = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(setting)
            UIApplication.shared.registerForRemoteNotifications()
        }
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.absoluteString.lowercased() == "bsignerapp://" {
//            Broadcaster.notify(bSignersNotificationOpenedDelegate.self) {
//                $0.notifyChooseSigners()
//            }
            pushChooseSignersViewController()
        } else {
            if let dict = url.getKeyVals() {
                let json = JSON(dict)
                let model = TransactionModel(json: json)
//                Broadcaster.notify(bSignersNotificationOpenedDelegate.self) {
//                    $0.notifyApproveTransaction(model: model)
//                }
                pushTransactionInfoViewController(model: model)
            }
        }
        return false
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func pushChooseSignersViewController() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "chooseSignersViewController") as! ChooseSignersViewController
        let navigationController = UINavigationController(rootViewController: vc)
        window?.rootViewController = navigationController
    }
    
    func pushTransactionInfoViewController(model:TransactionModel) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "transactionInfoViewController") as! TransactionInfoViewController
        vc.model = model
        let navigationController = UINavigationController(rootViewController: vc)
        window?.rootViewController = navigationController
    }
    
    func pushMainTabbarViewController(selectedIndex:Int = 0) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "mainTabbarViewController") as! MainTabbarViewController
        vc.selectedIndex = selectedIndex
        let navigationController = UINavigationController(rootViewController: vc)
        window?.rootViewController = navigationController
    }
    
    public func getDeviceToken() {
        
        self.setupOnsignal(launchOptions: nil)
        //Get token
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.badge, .alert , .sound]) { (greanted, error) in
                if greanted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                    
                }
            }
        } else {
            
            let setting = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(setting)
            UIApplication.shared.registerForRemoteNotifications()
        }
        
        
    }

}

