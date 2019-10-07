//
//  UserDefaultsHelper.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 9/30/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit

struct UserDefaultsHelper {
  
  private static let signerAccountsKey = "numberOfSignerAccounts"
  private static let accountCreatedKey = "isAccountCreated"
    
  static var numberOfSignerAccounts: Int {
    get { return UserDefaults.standard.integer(forKey: signerAccountsKey) }
    set { UserDefaults.standard.set(newValue, forKey: signerAccountsKey) }
  }
  
  static var accountStatus: AccountStatus {
    get {
      let accountStatusRawValue =  UserDefaults.standard.integer(forKey: accountCreatedKey)
      return AccountStatus(rawValue: accountStatusRawValue) ?? .notCreated
    }
    set { UserDefaults.standard.set(newValue.rawValue, forKey: accountCreatedKey) }
  }
}
