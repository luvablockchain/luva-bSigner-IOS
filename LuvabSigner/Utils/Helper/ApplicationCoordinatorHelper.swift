//
//  ApplicationCoordinatorHelper.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 9/30/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

enum AccountStatus: Int {
  case created = 2
  case waitingToBecomeSinger = 1
  case notCreated = 0
}

protocol bSignersNotificationOpenedDelegate: class {
    func notifyChooseSigners()
}


struct ApplicationCoordinatorHelper {
  
  static func logout() {
    
    UserDefaultsHelper.accountStatus = .notCreated
    ConfigModel.sharedInstance.enablePassCode = .off
    UserDefaults.standard.removeObject(forKey: "SIGNNATURE")
    KeychainWrapper.standard.removeAllKeys()
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
      else { return }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        appDelegate.applicationCoordinator.showMenuScreen()
    }
  }
}
