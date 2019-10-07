//
//  SettingsViewController.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 10/3/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit
import Eureka
import EZAlertController
import SwiftKeychainWrapper

class SettingsViewController: FormViewController {
    
    private var code: String = ""
    var isDisablePassCode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ConfigModel.sharedInstance.loadLocalized()
        title = "Settings".localizedString()
        loadForm()
    }
    func loadForm() {
        form +++
            Section(){ section in
                section.header = {
                    var header = HeaderFooterView<UIView>(.callback({
                        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 0))
                        return view
                    }))
                    header.height = {0}
                    return header
                }()
            }
            <<< SwitchRow() {
                $0.title = "Set Passcode".localizedString()
                $0.tag = "PassCode"
                if(ConfigModel.sharedInstance.enablePassCode == .on) {
                    $0.value = true
                    self.isDisablePassCode = true
                    ConfigModel.sharedInstance.disablePassCode = .off
                } else {
                    self.isDisablePassCode = false
                    $0.value = false
                    ConfigModel.sharedInstance.disablePassCode = .on
                }
            }.cellSetup { cell, row in
                cell.imageView?.image = UIImage.init(named: "ic_passcode")
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
            }.onChange { [weak self] in
                if $0.value == true {
                    if !self!.isDisablePassCode {
                        ConfigModel.sharedInstance.disablePassCode = .off
                    self?.pushToLockScreenViewController(delegate:self!,isCreateAccount: false)
                    }
                } else {
                    if self!.isDisablePassCode {
                        ConfigModel.sharedInstance.disablePassCode = .on
                        self?.pushToLockScreenViewController(delegate:self!,isCreateAccount: false)
                    }
                }
                
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
                if (ConfigModel.sharedInstance.enablePassCode == .on) {
                    cell.switchControl.isOn = true
                    row.value = true
                    ConfigModel.sharedInstance.enablePassCode = .on
                    self.isDisablePassCode = true
                    ConfigModel.sharedInstance.disablePassCode = .off
                } else {
                    cell.switchControl.isOn = false
                    row.value = false
                    self.isDisablePassCode = false
                    ConfigModel.sharedInstance.disablePassCode = .on
                    ConfigModel.sharedInstance.enablePassCode = .off
                }
            })
            <<< LabelRow () {
                $0.title = "Change Passcode".localizedString()
                $0.tag = "ChangePassCode"
                if (ConfigModel.sharedInstance.enablePassCode == .on) {
                    $0.cell.isUserInteractionEnabled = true
                    $0.cell.textLabel?.textColor = UIColor.darkText
                } else {
                    $0.cell.isUserInteractionEnabled = false
                    $0.cell.textLabel?.textColor = UIColor.lightGray
                }
                
            }.cellSetup({ (cell, row) in
                cell.imageView?.image = UIImage.init(named: "ic_changepass")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                cell.imageView?.tintColor = BaseViewController.MainColor
                cell.selectionStyle = UITableViewCell.SelectionStyle.default
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
                cell.height = { UITableView.automaticDimension }
                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            }).onCellSelection {[weak self] cell, row in
                ConfigModel.sharedInstance.passCodeType = .change
                self?.pushToLockScreenViewController(delegate:self!, isCreateAccount: false)
            }.cellUpdate({ (cell, row) in
                cell.imageView?.image = UIImage.init(named: "ic_changepass")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                cell.imageView?.tintColor = BaseViewController.MainColor
                if (ConfigModel.sharedInstance.enablePassCode == .on) {
                    cell.isUserInteractionEnabled = true
                    cell.textLabel?.textColor = UIColor.darkText
                } else {
                    cell.textLabel?.textColor = UIColor.lightGray
                    cell.isUserInteractionEnabled = false
                }
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            })
            
            <<< SwitchRow() {
                $0.title = "Enable unlock with Touch ID".localizedString()
                $0.tag = "TouchID"
                if(ConfigModel.sharedInstance.enablePassCode == .on) {
                    if ConfigModel.sharedInstance.enableTouchID == .on {
                        $0.cell.switchControl.isEnabled = true
                        $0.cell.switchControl.isOn = true
                        $0.cell.textLabel?.textColor = UIColor.darkText
                    } else {
                        $0.cell.textLabel?.textColor = UIColor.lightGray
                        $0.cell.switchControl.isEnabled = false
                        $0.cell.switchControl.isOn = false
                    }
                } else {
                    $0.cell.textLabel?.textColor = UIColor.lightGray
                    $0.cell.switchControl.isEnabled = false
                    if ConfigModel.sharedInstance.enableTouchID == .on {
                        $0.cell.switchControl.isOn = true
                    } else {
                        $0.cell.switchControl.isOn = false
                    }
                }
            }.cellSetup { cell, row in
                cell.imageView?.image = UIImage.init(named: "ic_faceID")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                cell.imageView?.tintColor = BaseViewController.MainColor
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
                
            }.onChange { [weak self] in
                if $0.value == true {
                    ConfigModel.sharedInstance.enableTouchID = .on
                } else {
                    ConfigModel.sharedInstance.enableTouchID = .off
                }
                ConfigModel.sharedInstance.saveConfigToDB()
            }.cellUpdate({ (cell, row) in
                cell.imageView?.image = UIImage.init(named: "ic_faceID")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                cell.imageView?.tintColor = BaseViewController.MainColor
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
                if ConfigModel.sharedInstance.enablePassCode == .on {
                    cell.textLabel?.textColor = UIColor.darkText
                    cell.switchControl.isEnabled = true
                    if ConfigModel.sharedInstance.enableTouchID == .on {
                        ConfigModel.sharedInstance.enableTouchID = .on
                        cell.switchControl.isOn = true
                    } else {
                        ConfigModel.sharedInstance.enableTouchID = .off
                        cell.switchControl.isOn = false
                    }
                } else {
                    cell.textLabel?.textColor = UIColor.lightGray
                    cell.switchControl.isEnabled = false
                    if ConfigModel.sharedInstance.enableTouchID == .on {
                        ConfigModel.sharedInstance.enableTouchID = .on
                        cell.switchControl.isOn = true
                    } else {
                        ConfigModel.sharedInstance.enableTouchID = .off
                        cell.switchControl.isOn = false
                    }
                }
                ConfigModel.sharedInstance.saveConfigToDB()
            })
            <<< PushRow <String>() {
                $0.title = "Automatically".localizedString()
                $0.tag = "SetTime"
                $0.selectorTitle = "Time".localizedString()
                $0.options = ["Immediately".localizedString(), "5 seconds".localizedString(), "10 seconds".localizedString(), "15 seconds".localizedString(), "30 seconds".localizedString()]
                if ConfigModel.sharedInstance.enablePassCode == .on {
                    $0.cell.isUserInteractionEnabled = true
                    $0.cell.textLabel?.textColor = UIColor.darkText
                    if let arr = $0.options {
                        if(ConfigModel.sharedInstance.configType == .now) {
                            $0.value = arr[0]
                        } else if (ConfigModel.sharedInstance.configType == .fiveSeconds) {
                            $0.value = arr[1]
                        } else if (ConfigModel.sharedInstance.configType == .tenSeconds) {
                            $0.value = arr[2]
                        } else if (ConfigModel.sharedInstance.configType == .fifteenSeconds) {
                            $0.value = arr[3]
                        } else if (ConfigModel.sharedInstance.configType == .thirtySenconds) {
                            $0.value = arr[4]
                        }
                    }
                } else {
                    $0.cell.isUserInteractionEnabled = false
                    $0.cell.textLabel?.textColor = UIColor.lightGray
                    if let arr = $0.options {
                        if(ConfigModel.sharedInstance.configType == .now) {
                            $0.value = arr[0]
                        } else if (ConfigModel.sharedInstance.configType == .fiveSeconds) {
                            $0.value = arr[1]
                        } else if (ConfigModel.sharedInstance.configType == .tenSeconds) {
                            $0.value = arr[2]
                        } else if (ConfigModel.sharedInstance.configType == .fifteenSeconds) {
                            $0.value = arr[3]
                        } else if (ConfigModel.sharedInstance.configType == .thirtySenconds) {
                            $0.value = arr[4]
                        }
                    }
                }
                
            }.cellSetup({ (cell, row) in
                cell.imageView?.image = UIImage.init(named: "ic_auto")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                cell.imageView?.tintColor = BaseViewController.MainColor
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            }).onChange({ (row) in
                if let arr = row.options {
                    if(row.value == arr[0]) {
                        ConfigModel.sharedInstance.configType = .now
                    } else if (row.value == arr[1]) {
                        ConfigModel.sharedInstance.configType = .fiveSeconds
                    } else if (row.value == arr[2]) {
                        ConfigModel.sharedInstance.configType = .tenSeconds
                    } else if (row.value == arr[3]) {
                        ConfigModel.sharedInstance.configType = .fifteenSeconds
                    } else if (row.value == arr[4]) {
                        ConfigModel.sharedInstance.configType = .thirtySenconds
                    }
                }
                row.reload()
                ConfigModel.sharedInstance.saveConfigToDB()
                
            }).cellUpdate({ (cell, row) in
                cell.imageView?.image = UIImage.init(named: "ic_auto")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                cell.imageView?.tintColor = BaseViewController.MainColor
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
                if ConfigModel.sharedInstance.enablePassCode == .on {
                    cell.isUserInteractionEnabled = true
                    cell.textLabel?.textColor = UIColor.darkText
                    if let arr = row.options {
                        if(ConfigModel.sharedInstance.configType == .now) {
                            row.value = arr[0]
                        } else if (ConfigModel.sharedInstance.configType == .fiveSeconds) {
                            row.value = arr[1]
                        } else if (ConfigModel.sharedInstance.configType == .tenSeconds) {
                            row.value = arr[2]
                        } else if (ConfigModel.sharedInstance.configType == .fifteenSeconds) {
                            row.value = arr[3]
                        } else if (ConfigModel.sharedInstance.configType == .thirtySenconds) {
                            row.value = arr[4]
                        }
                    }
                } else {
                    cell.isUserInteractionEnabled = false
                    cell.textLabel?.textColor = UIColor.lightGray
                    if let arr = row.options {
                        if(ConfigModel.sharedInstance.configType == .now) {
                            row.value = arr[0]
                        } else if (ConfigModel.sharedInstance.configType == .fiveSeconds) {
                            row.value = arr[1]
                        } else if (ConfigModel.sharedInstance.configType == .tenSeconds) {
                            row.value = arr[2]
                        } else if (ConfigModel.sharedInstance.configType == .fifteenSeconds) {
                            row.value = arr[3]
                        } else if (ConfigModel.sharedInstance.configType == .thirtySenconds) {
                            row.value = arr[4]
                        }
                    }
                }
            })
            <<< ActionSheetRow<String>() {
                
                $0.title = "App language".localizedString()
                $0.selectorTitle = "Select language"
                $0.options = ["Việt Nam", "English"]
                if(ConfigModel.sharedInstance.languageApp == .en) {
                    $0.value = $0.options?.last
                } else {
                    $0.value = $0.options?.first
                }
            }.cellSetup({ (cell, row) in
                cell.imageView?.image = UIImage.init(named: "ic_language")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                cell.imageView?.tintColor = BaseViewController.MainColor
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            }).onChange({ (row) in
                var content = ""
                if(row.value == row.options!.first) {
                    ConfigModel.sharedInstance.languageApp = .vi
                    ConfigModel.sharedInstance.saveToDB()
                    ConfigModel.sharedInstance.loadLocalized()
                    content =  "\("Changed".localizedString()) \("languge to".localizedString()) Việt Nam"
                } else {
                    ConfigModel.sharedInstance.languageApp = .en
                    ConfigModel.sharedInstance.saveToDB()
                    ConfigModel.sharedInstance.loadLocalized()
                    content =  "\("Changed".localizedString()) \("languge to".localizedString()) English"
                }
                EZAlertController.alert("Force restart app".localizedString(), message:"\("Change".localizedString()) \("App language".localizedString()) \("require restart app".localizedString())", buttons: ["Restart".localizedString(), "Cancel".localizedString()]) { (alertAction, position) -> Void in
                    if position == 0 {
                        self.exitAppAndRequestReopenNotify(content: content)
                    } else if position == 1 {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                
            })
            <<< LabelRow () {
                $0.title = "Logout".localizedString()
            }.cellSetup({ (cell, row) in
                cell.selectionStyle = UITableViewCell.SelectionStyle.default
                cell.imageView?.image = UIImage.init(named: "ic_logout")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                cell.imageView?.tintColor = UIColor.red
                cell.detailTextLabel?.textColor = UIColor.red
                cell.textLabel?.textColor = UIColor.red
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            }).cellUpdate { cell, row in
                cell.textLabel?.textColor = UIColor.red
                
            }.onCellSelection {[weak self] cell, row in
                row.reload()
                ApplicationCoordinatorHelper.logout()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

extension SettingsViewController: LockScreenViewControllerDelegate {
    func didChangePassCode() {
        self.code = ""
        ConfigModel.sharedInstance.passCodeType = .confirm
        pushToLockScreenViewController(delegate: self, isCreateAccount: false)
    }
    func didInPutPassCodeSuccess(_ pass: String) {
        if ConfigModel.sharedInstance.passCodeType == .confirm {
            if code.isEmpty {
                code = pass
                pushToLockScreenViewController(delegate: self, passCode: pass, isCreateAccount: false)
            } else {
                if code == pass {
                    self.navigationController?.popToViewController(self, animated: true)
                }
            }
        } else {
            if code.isEmpty {
                code = pass
                pushToLockScreenViewController(delegate: self, passCode: pass, isCreateAccount: false)
            } else {
                if code == pass {
                    self.navigationController?.popToViewController(self, animated: true)
                }
            }
        }
    }
    func didConfirmPassCode() {
        self.code = ""
        self.form.rowBy(tag: "PassCode")?.updateCell()
        self.form.rowBy(tag: "ChangePassCode")?.updateCell()
        self.form.rowBy(tag: "TouchID")?.updateCell()
        self.form.rowBy(tag: "SetTime")?.updateCell()
        self.navigationController?.popToViewController(self, animated: true)
    }
    func didPopViewController() {
        self.code = ""
        ConfigModel.sharedInstance.passCodeType = .normal
        self.form.rowBy(tag: "PassCode")?.updateCell()
        self.form.rowBy(tag: "ChangePassCode")?.updateCell()
        self.form.rowBy(tag: "TouchID")?.updateCell()
        self.form.rowBy(tag: "SetTime")?.updateCell()
        ConfigModel.sharedInstance.saveConfigToDB()
        self.isDisablePassCode = true
        self.navigationController?.popToViewController(self, animated: true)
    }
    
    func didConfirmPassCodeSuccess() {
        self.navigationController?.popToViewController(self, animated: true)
    }
    
    func didDisablePassCodeSuccess() {
        self.code = ""
        ConfigModel.sharedInstance.enablePassCode = .off
        ConfigModel.sharedInstance.disablePassCode = .on
        self.form.rowBy(tag: "PassCode")?.updateCell()
        self.form.rowBy(tag: "ChangePassCode")?.updateCell()
        self.form.rowBy(tag: "TouchID")?.updateCell()
        self.form.rowBy(tag: "SetTime")?.updateCell()
        KeychainWrapper.standard.removeObject(forKey: "MYPASS")
        ConfigModel.sharedInstance.saveConfigToDB()
        self.isDisablePassCode = false
        self.navigationController?.popToViewController(self, animated: true)
    }
}
