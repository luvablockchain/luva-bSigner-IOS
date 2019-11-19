//
//  LockScreenViewController.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 9/23/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit
import SmileLock
import SwiftKeychainWrapper
import EZAlertController
import PKHUD

protocol LockScreenViewControllerDelegate:NSObject {
    func didInPutPassCodeSuccess(_ pass:String)
    func didConfirmPassCode()
    func didChangePassCode()
    func didPopViewController()
    func didConfirmPassCodeSuccess()
    func didDisablePassCodeSuccess()
}


class LockScreenViewController: UIViewController {
    
    @IBOutlet weak var btnBack: UIButton!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var svPass: UIStackView!
    
    private var alertView: UIView!
    
    private var textLabel: UILabel!

    
    private var passwordContainerView: PasswordContainerView!
    let kPasswordDigit = 6
    var passCode: String = ""
    var isEnableBackButton = false
    var mnemonic: String?
    var isCreateAccount = false
    var isDisablePassCode = false
    weak var delegate:LockScreenViewControllerDelegate?
    var model:[SignatureModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ConfigModel.sharedInstance.loadLocalized()
        navigationController?.setNavigationBarHidden(true, animated: true)
        let imgBack = UIImage.init(named: "ic_back")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        btnBack.setImage(imgBack, for: .normal)
        btnBack.tintColor = BaseViewController.MainColor
        btnBack.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        if isEnableBackButton {
            btnBack.isHidden = false
        } else {
            btnBack.isHidden = true
        }
        passwordContainerView = PasswordContainerView.create(in: svPass, digit: kPasswordDigit)
        let imgDelete = UIImage.init(named: "ic_backspace")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        passwordContainerView.deleteButton.setImage(imgDelete, for: .normal)
        passwordContainerView.deleteButtonLocalizedTitle = ""
        passwordContainerView.tintColor = BaseViewController.MainColor
        passwordContainerView.touchAuthenticationButton.tintColor = .white
        passwordContainerView.highlightedColor = UIColor.init(rgb: 0x555555)
        self.view.backgroundColor = .white
        lblTitle.textColor = .darkText
        passwordContainerView.delegate = self
        passwordContainerView.touchAuthenticationButton.isEnabled = false
        if let _ = KeychainWrapper.standard.string(forKey: "MYPASS") {
            if ConfigModel.sharedInstance.passCodeType == .change {
                lblTitle.text = "Enter Current Passcode".localizedString()
            } else if ConfigModel.sharedInstance.passCodeType == .confirm {
                if passCode.isEmpty {
                    lblTitle.text = "Enter New Passcode".localizedString()
                } else {
                    lblTitle.text = "Confirm New Passcode".localizedString()
                }
            } else if ConfigModel.sharedInstance.passCodeType == .normal {
                lblTitle.text = "Enter Passcode".localizedString()
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    if ConfigModel.sharedInstance.enablePassCode == .on && ConfigModel.sharedInstance.enableTouchID == .on {
                        self.passwordContainerView.touchAuthentication()
                    }
                }
            }
        } else {
            if passCode.isEmpty {
                lblTitle.text = "Enter New Passcode".localizedString()
            } else {
                lblTitle.text = "Confirm New Passcode".localizedString()
            }
        }
    }
    
    func removeAlertText() {
        self.alertView.removeFromSuperview()
    }

    func showAlertWithText(text: String) {
          let text = text.trimmed()
          if(text == "") {
              return
          }
          if(self.alertView == nil) {
              self.alertView = UIView(frame: CGRect.zero)
              self.alertView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
              self.textLabel = UILabel(frame: CGRect.zero)
              self.textLabel.textAlignment = NSTextAlignment.center
          } else {
            removeAlertText()
          }
          
          self.textLabel.text = text
          self.textLabel.textColor = UIColor.white
          
          self.alertView.addSubview(self.textLabel)
            let _ = self.textLabel.sd_layout().leftSpaceToView(self.alertView, 10)?.rightSpaceToView(self.alertView, 10)?.topSpaceToView(self.alertView, 10)?.autoHeightRatio(0)
          UIApplication.shared.keyWindow?.addSubview(self.alertView)
          
          let _ = self.alertView.sd_layout()
              .centerXEqualToView(self.alertView.superview)!
              .centerYEqualToView(self.alertView.superview)!
              .widthIs(200)
          
          self.alertView.setupAutoHeight(withBottomView: self.textLabel, bottomMargin: 10)
          self.alertView.sd_cornerRadius = NSNumber(value: 5)
          
          let deadlineTime = DispatchTime.now() + 2.5
          DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.removeAlertText()
          }
      }
    
    @IBAction func tappedBackButton(_ sender: Any) {
        if isCreateAccount {
            EZAlertController.alert("Are you sure".localizedString() + "?", message: "This action will cancel account creation".localizedString() + ". " + "Shown recovery phrase will be deleted".localizedString(), buttons: ["Cancel".localizedString(), "OK".localizedString()]) { (alertAction, position) -> Void in
                if position == 0 {
                    self.dismiss(animated: true, completion: nil)
                } else if position == 1 {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        } else {
            delegate?.didPopViewController()
        }
    }
}

extension LockScreenViewController: PasswordInputCompleteProtocol {
    func passwordInputComplete(_ passwordContainerView: PasswordContainerView, input: String) {
        if let passWord = KeychainWrapper.standard.string(forKey: "MYPASS") {
            if ConfigModel.sharedInstance.passCodeType == .change {
                if passWord == input {
                    delegate?.didChangePassCode()
                } else {
                    passwordContainerView.wrongPassword()
                }
            } else if ConfigModel.sharedInstance.passCodeType == .confirm {
                if passCode.isEmpty {
                    delegate?.didInPutPassCodeSuccess(input)
                } else {
                    if passCode == input {
                        KeychainWrapper.standard.set(passCode, forKey: "MYPASS")
                        ConfigModel.sharedInstance.disablePassCode = .off
                        ConfigModel.sharedInstance.enablePassCode = .on
                        ConfigModel.sharedInstance.passCodeType = .normal
                        ConfigModel.sharedInstance.saveConfigToDB()
                        delegate?.didConfirmPassCode()
                    } else {
                        passwordContainerView.wrongPassword()
                    }
                }
            } else if ConfigModel.sharedInstance.passCodeType == .normal {
                if isDisablePassCode {
                    if passWord == input {
                        delegate?.didDisablePassCodeSuccess()
                    } else {
                        passwordContainerView.wrongPassword()
                    }
                } else {
                    if passWord == input {
                        delegate?.didConfirmPassCodeSuccess()
                    } else {
                        passwordContainerView.wrongPassword()
                    }
                }
            }
        } else {
            if passCode.isEmpty {
                delegate?.didInPutPassCodeSuccess(input)
            } else {
                if passCode == input {
                    if bSignerServiceManager.sharedInstance.checkStatus {
                        KeychainWrapper.standard.set(passCode, forKey: "MYPASS")
                        if let mnemonic = self.mnemonic {
                            HUD.show(.labeledProgress(title: nil, subtitle: "Loading..."))
                            DispatchQueue.global(qos: .background).async {
                                let publickey = MnemonicHelper.getKeyPairFrom(mnemonic).accountId
                                self.model.append(SignatureModel.init(title: "Signature".localizedString() + " 0", publicKey: publickey,mnemonic: mnemonic))
                                let data = NSKeyedArchiver.archivedData(withRootObject: self.model)
                                DispatchQueue.main.async {
                                    if publickey != ""
                                    {
                                        bSignerServiceManager.sharedInstance.taskGetSubscribeSignature(userId: bSignerServiceManager.sharedInstance.oneSignalUserId,publicKey: publickey).continueOnSuccessWith(continuation: { task in
                                            KeychainWrapper.standard.set(data, forKey: "SIGNATURE")
                                            HUD.hide()
                                            self.showAlertWithText(text: "Create signature success".localizedString())
                                        bSignerServiceManager.sharedInstance.checkStatus = false
                                            self.pushChooseSignersViewController()
                                        }).continueOnErrorWith(continuation: { error in
                                            HUD.hide()
                                        self.navigationController?.popToRootViewController(animated: true)

                                            self.showAlertWithText(text: "Some thing went wrong".localizedString() + ". " + "Please try again".localizedString() + ".")
                                        })
                                        
                                    }
                                }
                            }
                        }
                        ConfigModel.sharedInstance.disablePassCode = .on
                        ConfigModel.sharedInstance.enablePassCode = .on
                        ConfigModel.sharedInstance.saveConfigToDB()
                        delegate?.didConfirmPassCode()
                    } else {
                        if isCreateAccount {
                            KeychainWrapper.standard.set(passCode, forKey: "MYPASS")
                            if let mnemonic = self.mnemonic {
                                HUD.show(.labeledProgress(title: nil, subtitle: "Loading..."))
                                DispatchQueue.global(qos: .background).async {
                                    let publickey = MnemonicHelper.getKeyPairFrom(mnemonic).accountId
                                    self.model.append(SignatureModel.init(title: "Signature".localizedString() + " 0", publicKey: publickey,mnemonic: mnemonic))
                                    let data = NSKeyedArchiver.archivedData(withRootObject: self.model)
                                    DispatchQueue.main.async {
                                        if publickey != ""
                                        {
                                        bSignerServiceManager.sharedInstance.taskGetSubscribeSignature(userId: bSignerServiceManager.sharedInstance.oneSignalUserId,publicKey: publickey).continueOnSuccessWith(continuation: { task in
                                            KeychainWrapper.standard.set(data, forKey: "SIGNATURE")
                                                HUD.hide()
                                                self.showAlertWithText(text: "Create signature success".localizedString())
                                                self.pushMainTabbarViewController()
                                            }).continueOnErrorWith(continuation: { error in
                                            self.navigationController?.popToRootViewController(animated: true)
                                                HUD.hide()
                                                self.showAlertWithText(text: "Some thing went wrong".localizedString() + ". " + "Please try again".localizedString() + ".")
                                            })
                                        }
                                    }
                                }
                            }
                            ConfigModel.sharedInstance.disablePassCode = .on
                            ConfigModel.sharedInstance.enablePassCode = .on
                            ConfigModel.sharedInstance.saveConfigToDB()
                            delegate?.didConfirmPassCode()
                        } else {
                            KeychainWrapper.standard.set(passCode, forKey: "MYPASS")
                            ConfigModel.sharedInstance.disablePassCode = .on
                            ConfigModel.sharedInstance.enablePassCode = .on
                            ConfigModel.sharedInstance.saveConfigToDB()
                            delegate?.didConfirmPassCode()
                        }
                    }

                } else {
                    passwordContainerView.wrongPassword()
                }
            }
        }
    }
    
    func touchAuthenticationComplete(_ passwordContainerView: PasswordContainerView, success: Bool, error: Error?) {
        if isDisablePassCode {
            if success {
                delegate?.didDisablePassCodeSuccess()
            } else {
                passwordContainerView.clearInput()
            }
        } else {
            if success {
                delegate?.didConfirmPassCodeSuccess()
            } else {
                passwordContainerView.clearInput()
            }
        }
    }
}
