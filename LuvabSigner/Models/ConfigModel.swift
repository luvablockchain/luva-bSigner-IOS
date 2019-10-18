//
//  ConfigModel.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 9/23/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit
import LKDBHelper

public enum ConfigLockScreenType: Int {
    case now = 1, fiveSeconds = 2, tenSeconds = 3 , fifteenSeconds = 4, thirtySenconds = 5
    
    var second: Int {
        switch self {
        case .now:
            return 0
        case .fiveSeconds:
            return 5

        case .tenSeconds:
            return 10

        case .fifteenSeconds:
            return 15

        case .thirtySenconds:
            return 30
        }
    }
}

public enum EnablePassCode: Int {
    case on = 1, off = 2
}

public enum EnableTouchID: Int {
    case on = 1, off = 2
}

public enum EnableTransaction: Int {
    case on = 1, off = 2
}
public enum DisablePassCode: Int {
    case on = 1, off = 2
}


public enum PassCodeType: Int {
    case change = 1, confirm = 2, normal = 3, off = 4
}

public enum LanguageApp: Int {
    case en = 1, vi = 2
}

public enum AccountType: Int {
    case create = 1, normal = 2
}

public enum CheckPassType: Int {
    case on = 1, off = 2
}

class ConfigModel: NSObject {
    
    @objc var identifier: String = "1"

    @objc var rawConfigType: Int = ConfigLockScreenType.now.rawValue
    var configType: ConfigLockScreenType {
        get {
            return ConfigLockScreenType(rawValue: rawConfigType) ?? ConfigLockScreenType.now
        }
        set {
            rawConfigType = newValue.rawValue
        }
    }
    
    @objc var rawLanguageApp: Int = LanguageApp.vi.rawValue
    
    var languageApp: LanguageApp {
        get {
            return LanguageApp(rawValue: rawLanguageApp) ?? LanguageApp.en
        }
        set {
            rawLanguageApp = newValue.rawValue
        }
    }
    
    @objc var rawCheckPassType: Int = CheckPassType.off.rawValue
    
    var checkPassType: CheckPassType {
        get {
            return CheckPassType(rawValue: rawCheckPassType) ?? CheckPassType.off
        }
        set {
            rawCheckPassType = newValue.rawValue
        }
    }

    
    @objc var rawEnablePassCode: Int = EnablePassCode.off.rawValue
    var enablePassCode: EnablePassCode {
        get {
            return EnablePassCode(rawValue: rawEnablePassCode) ?? EnablePassCode.off
        }
        set {
            rawEnablePassCode = newValue.rawValue
        }
    }
    
    @objc var rawAccountType: Int = AccountType.normal.rawValue
    
    var accountType: AccountType {
        get {
            return AccountType(rawValue: rawAccountType) ?? AccountType.normal
        }
        set {
            rawAccountType = newValue.rawValue
        }
    }

    @objc var rawDisablePassCode: Int = DisablePassCode.off.rawValue
    var disablePassCode: DisablePassCode {
        get {
            return DisablePassCode(rawValue: rawDisablePassCode) ?? DisablePassCode.off
        }
        set {
            rawDisablePassCode = newValue.rawValue
        }
    }

    @objc var rawPassCodeType: Int = PassCodeType.normal.rawValue
    var passCodeType: PassCodeType {
        get {
            return PassCodeType(rawValue: rawPassCodeType) ?? PassCodeType.normal
        }
        set {
            rawPassCodeType = newValue.rawValue
        }
    }
    
    @objc var rawEnableTouchID: Int = EnableTouchID.off.rawValue
    var enableTouchID: EnableTouchID {
        get {
            return EnableTouchID(rawValue: rawEnableTouchID) ?? EnableTouchID.off
        }
        set {
            rawEnableTouchID = newValue.rawValue
        }
    }
    @objc var rawEnableTransaction: Int = EnableTransaction.off.rawValue
    var enableTransaction: EnableTransaction {
        get {
            return EnableTransaction(rawValue: rawEnableTransaction) ?? EnableTransaction.off
        }
        set {
            rawEnableTransaction = newValue.rawValue
        }
    }

    
    override static func getPrimaryKey() -> String {
        return "identifier"
    }
    override static func getTableName() -> String {
        return "ConfigTable"
    }
    
    
    //MARK: Shared Instance
    
    public static let sharedInstance : ConfigModel = {
        if let model = ConfigModel.search(withWhere: nil, orderBy: nil, offset: 0, count: 1)?.firstObject as? ConfigModel {
            return model
        }

        let instance = ConfigModel()
        if let substring = Locale.preferredLanguages.first?.prefix(2) {
            let language = String(substring).lowercased()
            if(language == "vi") {
                instance.languageApp = LanguageApp.vi
            } else {
                instance.languageApp = LanguageApp.en
            }
            
        }
        instance.saveToDB()
        return instance
    }()
    
    public func saveConfigToDB() {
        self.saveToDB()
    }
    
    func loadLocalized() {
        if(ConfigModel.sharedInstance.languageApp == .vi) {
            Bundle.setLanguage("vi")
        } else {
            Bundle.setLanguage("en")
        }
    }
}
