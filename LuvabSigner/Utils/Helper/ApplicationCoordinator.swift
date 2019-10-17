//
//  ApplicationCoordinator.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 9/30/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit
import UserNotifications
import SwiftKeychainWrapper

class ApplicationCoordinator {
    private let window: UIWindow?
    
    let accountStatus: AccountStatus
    
    init(window: UIWindow?) {
        self.window = window
        accountStatus = UserDefaultsHelper.accountStatus
    }
    
    func start(appDelegate: AppDelegate) {
        openStartScreen()
    }
    
    func showMenuScreen() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "signUpViewController") as! SignUpViewController
        let navigationController = UINavigationController(rootViewController: vc)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    func showPinScreen() {
        
    }
    
    func showMainScreen() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "mainTabbarViewController") as! MainTabbarViewController
        let navigationController = UINavigationController(rootViewController: vc)
        window?.rootViewController = navigationController
    }
    
    private func openStartScreen() {
        switch accountStatus {
        case .notCreated:
            KeychainWrapper.standard.removeAllKeys()
            showMenuScreen()
        case .waitingToBecomeSinger:
            self.showMainScreen()
        case .created:
            showPinScreen()
        }
    }
    
}
