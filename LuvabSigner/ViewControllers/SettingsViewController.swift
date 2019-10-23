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
    
    var passCodeRow: SwitchRow!
    
    var changePassRow: LabelRow!
    
    var touchIDRow: SwitchRow!
    
    var timeRow: PushRow<String>!
    
    var helpRow: LabelRow!
    
    var termsRow: LabelRow!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ConfigModel.sharedInstance.loadLocalized()
        title = "Settings".localizedString()
        Broadcaster.register(bSignersNotificationOpenedDelegate.self, observer: self)
        loadForm()
    }
    
    func loadForm() {
        
        self.passCodeRow = SwitchRow() {
            $0.title = "Set Passcode".localizedString()
            $0.tag = "PassCode"
            if(ConfigModel.sharedInstance.enablePassCode == .on) {
                $0.value = true
                $0.cell.switchControl.isOn = true
                ConfigModel.sharedInstance.disablePassCode = .on
            } else {
                $0.value = false
                $0.cell.switchControl.isOn = false
                ConfigModel.sharedInstance.disablePassCode = .off
            }
        }.cellSetup { cell, row in
            cell.imageView?.image = UIImage.init(named: "ic_passcode")
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
            self.setTextColor(textLabel: cell.textLabel!)
        }.onChange { [weak self] in
            if $0.value == true {
                if ConfigModel.sharedInstance.disablePassCode == .off {
                    self?.pushToLockScreenViewController(delegate:self!,isCreateAccount: false, isDisablePass: false)
                }
                
            } else {
                if ConfigModel.sharedInstance.disablePassCode == .on {
                    self?.pushToLockScreenViewController(delegate:self!,isCreateAccount: false, isDisablePass: true)
                }
            }
            
        }.cellUpdate({ (cell, row) in
            cell.imageView?.image = UIImage.init(named: "ic_passcode")
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        })

        
        self.changePassRow = LabelRow () {
            $0.title = "Change Passcode".localizedString()
            $0.tag = "ChangePassCode"
            if (ConfigModel.sharedInstance.enablePassCode == .on) {
                $0.cell.isUserInteractionEnabled = true
                self.setTextColor(textLabel: $0.cell.textLabel!)
                // $0.cell.textLabel?.textColor = UIColor.darkText
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
            self.setTextColor(textLabel:cell.textLabel!)
        }).onCellSelection {[weak self] cell, row in
            ConfigModel.sharedInstance.passCodeType = .change
            self?.pushToLockScreenViewController(delegate:self!, isCreateAccount: false)
        }.cellUpdate({ (cell, row) in
            cell.imageView?.image = UIImage.init(named: "ic_changepass")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            cell.imageView?.tintColor = BaseViewController.MainColor
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            if ConfigModel.sharedInstance.enablePassCode == .on {
                self.setTextColor(textLabel:cell.textLabel!)
            } else {
                cell.textLabel?.textColor = .lightGray
            }

        })
        
        self.touchIDRow = SwitchRow() {
            $0.title = "Enable unlock with Touch ID or Face ID".localizedString()
            $0.tag = "TouchID"
            self.setTextColor(textLabel:$0.cell.textLabel!)

            if ConfigModel.sharedInstance.enablePassCode == .on {
                if ConfigModel.sharedInstance.enableTouchID == .on {
                    $0.value = true
                    $0.cell.switchControl.isOn = true
                } else {
                    $0.value = false
                    $0.cell.switchControl.isOn = false
                }
                self.setTextColor(textLabel:$0.cell.textLabel!)
                $0.cell.isUserInteractionEnabled = true
            } else {
                $0.cell.textLabel?.textColor = .lightGray
                if ConfigModel.sharedInstance.enableTouchID == .on {
                    $0.value = true
                    $0.cell.switchControl.isOn = true
                } else {
                    $0.value = false
                    $0.cell.switchControl.isOn = false
                }
                $0.cell.isUserInteractionEnabled = false
            }
            
        }.cellSetup { cell, row in
            cell.imageView?.image = UIImage.init(named: "ic_faceID")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            cell.imageView?.tintColor = BaseViewController.MainColor
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
            self.setTextColor(textLabel:cell.textLabel!)
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
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
            cell.textLabel?.numberOfLines = 0
            if ConfigModel.sharedInstance.enablePassCode == .on {
                self.setTextColor(textLabel:cell.textLabel!)
            } else {
                cell.textLabel?.textColor = .lightGray
            }
        })
        
        self.timeRow = PushRow <String>() {
            $0.title = "Automatically".localizedString()
            $0.tag = "SetTime"
            $0.selectorTitle = "Time".localizedString()
            $0.options = ["Immediately".localizedString(), "5 seconds".localizedString(), "10 seconds".localizedString(), "15 seconds".localizedString(), "30 seconds".localizedString()]
            if ConfigModel.sharedInstance.enablePassCode == .on {
                $0.cell.isUserInteractionEnabled = true
                //$0.cell.textLabel?.textColor = UIColor.darkText
                self.setTextColor(textLabel:$0.cell.textLabel!)
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
            self.setTextColor(textLabel:cell.textLabel!)
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
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
            if ConfigModel.sharedInstance.enablePassCode == .on {
                self.setTextColor(textLabel:cell.textLabel!)
            } else {
                cell.textLabel?.textColor = .lightGray
            }

        })
        
        self.helpRow = LabelRow () {
            $0.title = "Frequently Asked Questions".localizedString()
        }.cellSetup({ (cell, row) in
            cell.imageView?.image = UIImage.init(named: "ic_help")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            cell.imageView?.tintColor = BaseViewController.MainColor
            cell.selectionStyle = UITableViewCell.SelectionStyle.default
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
            cell.height = { UITableView.automaticDimension }
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            self.setTextColor(textLabel:cell.textLabel!)
        }).onCellSelection {[weak self] cell, row in
        }.cellUpdate({ (cell, row) in
            cell.imageView?.image = UIImage.init(named: "ic_help")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            cell.imageView?.tintColor = BaseViewController.MainColor
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        })
        
        self.termsRow = LabelRow () {
            $0.title = "Term of service".localizedString()
        }.cellSetup({ (cell, row) in
            cell.imageView?.image = UIImage.init(named: "ic_policy")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            cell.imageView?.tintColor = BaseViewController.MainColor
            cell.selectionStyle = UITableViewCell.SelectionStyle.default
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
            cell.height = { UITableView.automaticDimension }
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            self.setTextColor(textLabel:cell.textLabel!)
        }).onCellSelection {[weak self] cell, row in
        }.cellUpdate({ (cell, row) in
            cell.imageView?.image = UIImage.init(named: "ic_policy")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            cell.imageView?.tintColor = BaseViewController.MainColor
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        })


        
        
        form
            +++
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
            <<<
            self.passCodeRow
            <<<
            self.changePassRow
            <<<
            self.touchIDRow
            <<<
            self.timeRow
            +++ Section(){ section in
                section.header = {
                    var header = HeaderFooterView<UIView>(.callback({
                        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 0))
                        return view
                    }))
                    header.height = {0}
                    return header
                }()
            }
            <<<
            self.termsRow
            <<<
            self.helpRow
            +++ Section(){ section in
                section.header = {
                    var header = HeaderFooterView<UIView>(.callback({
                        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 0))
                        return view
                    }))
                    header.height = {0}
                    return header
                }()
            }
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
                self.setTextColor(textLabel: cell.textLabel!)
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
                
            }).cellUpdate({ (cell, row) in
                cell.imageView?.image = UIImage.init(named: "ic_language")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                cell.imageView?.tintColor = BaseViewController.MainColor
                self.setTextColor(textLabel: cell.textLabel!)
            })
            +++ Section(){ section in
                section.header = {
                    var header = HeaderFooterView<UIView>(.callback({
                        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 0))
                        return view
                    }))
                    header.height = {0}
                    return header
                }()
            }
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
            }).onCellSelection {[weak self] cell, row in
                row.reload()
                EZAlertController.alert("", message:"You want to exit this application".localizedString() + ".", buttons: ["Ok".localizedString(), "Cancel".localizedString()]) { (alertAction, position) -> Void in
                    if position == 0 {
                       exit(0)
                    } else if position == 1 {
                        self!.dismiss(animated: true, completion: nil)
                    }
                }

                //ApplicationCoordinatorHelper.logout()
            }.cellUpdate({ (cell, row) in
                cell.imageView?.image = UIImage.init(named: "ic_logout")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                cell.imageView?.tintColor = UIColor.red
                cell.textLabel?.textColor = UIColor.red
            })
            +++
            Section()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func setTextColor(textLabel:UILabel) {
        if #available(iOS 12.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                textLabel.textColor = .white
            } else {
                textLabel.textColor = .darkText
            }
        }
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
        self.passCodeRow.value = true
        self.passCodeRow.cell.switchControl.isOn = true
        self.changePassRow.cell.isUserInteractionEnabled = true
        self.touchIDRow.cell.isUserInteractionEnabled = true
        self.timeRow.cell.isUserInteractionEnabled = true
        self.passCodeRow.cell.textLabel?.textColor = .darkText
        self.changePassRow.cell.textLabel?.textColor = .darkText
        self.touchIDRow.cell.textLabel?.textColor = .darkText
        self.timeRow.cell.textLabel?.textColor = .darkText
        self.navigationController?.popToViewController(self, animated: true)
    }
    
    func didPopViewController() {
        self.code = ""
        ConfigModel.sharedInstance.passCodeType = .normal
        if ConfigModel.sharedInstance.enablePassCode == .on {
            ConfigModel.sharedInstance.enablePassCode = .on
            ConfigModel.sharedInstance.disablePassCode = .on
            self.passCodeRow.value = true
            self.passCodeRow.cell.switchControl.isOn = true
            self.changePassRow.cell.isUserInteractionEnabled = true
            self.touchIDRow.cell.switchControl.isEnabled = true
            self.timeRow.cell.isUserInteractionEnabled = true
            self.passCodeRow.cell.textLabel?.textColor = .darkText
            self.changePassRow.cell.textLabel?.textColor = .darkText
            self.touchIDRow.cell.textLabel?.textColor = .darkText
            self.timeRow.cell.textLabel?.textColor = .darkText
        } else {
            ConfigModel.sharedInstance.enablePassCode = .off
            ConfigModel.sharedInstance.disablePassCode = .off
            self.passCodeRow.value = false
            self.passCodeRow.cell.switchControl.isOn = false
            self.changePassRow.cell.isUserInteractionEnabled = false
            self.touchIDRow.cell.switchControl.isEnabled = false
            self.timeRow.cell.isUserInteractionEnabled = false
            self.passCodeRow.cell.textLabel?.textColor = .lightGray
            self.changePassRow.cell.textLabel?.textColor = .lightGray
            self.touchIDRow.cell.textLabel?.textColor = .lightGray
            self.timeRow.cell.textLabel?.textColor = .lightGray
        }
        ConfigModel.sharedInstance.saveConfigToDB()
        self.navigationController?.popToViewController(self, animated: true)
    }
    
    func didConfirmPassCodeSuccess() {
        self.navigationController?.popToViewController(self, animated: true)
    }
    
    func didDisablePassCodeSuccess() {
        self.code = ""
        ConfigModel.sharedInstance.enablePassCode = .off
        self.passCodeRow.value = false
        self.passCodeRow.cell.switchControl.isOn = false
        self.changePassRow.cell.isUserInteractionEnabled = false
        self.touchIDRow.cell.isUserInteractionEnabled = false
        self.timeRow.cell.isUserInteractionEnabled = false
        self.passCodeRow.cell.textLabel?.textColor = .lightGray
        self.changePassRow.cell.textLabel?.textColor = .lightGray
        self.touchIDRow.cell.textLabel?.textColor = .lightGray
        self.timeRow.cell.textLabel?.textColor = .lightGray
        KeychainWrapper.standard.removeObject(forKey: "MYPASS")
        ConfigModel.sharedInstance.disablePassCode = .off
        ConfigModel.sharedInstance.saveConfigToDB()
        self.navigationController?.popToViewController(self, animated: true)
    }
}

extension SettingsViewController: bSignersNotificationOpenedDelegate {
    func notifyApproveTransaction(model: TransactionModel) {
        pushChooseSignersViewController(model: model)
    }
    
    func notifyChooseSigners() {
        self.pushChooseSignersViewController()
    }
}
