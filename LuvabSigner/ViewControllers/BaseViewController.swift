//
//  BaseViewController.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 9/20/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    static let MainColor = UIColor.init(rgb: 0x70b500)
    
    var btnBack:UIButton?
    var btnHelp:UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ConfigModel.sharedInstance.loadLocalized()
        if let _ = navigationController {
            btnBack = UIButton.init(type: .system)
            if #available(iOS 11.0, *) {
                btnBack?.contentHorizontalAlignment = .leading
            }
            btnBack!.setImage(UIImage(named: "ic_back")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
            btnBack!.tintColor = BaseViewController.MainColor
            btnBack!.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            btnBack!.addTarget(self, action:#selector(tappedAtLeftButton), for: .touchUpInside)
            let leftBarButton = UIBarButtonItem()
            leftBarButton.customView = btnBack
            self.navigationItem.leftBarButtonItem = leftBarButton
            
            btnHelp = UIButton.init(type: .system)
            if #available(iOS 11.0, *) {
                btnHelp?.contentHorizontalAlignment = .trailing
            }
            btnHelp!.setImage(UIImage(named: "ic_help")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
            btnHelp!.tintColor = BaseViewController.MainColor
            btnHelp!.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            btnHelp!.addTarget(self, action:#selector(tappedAtRightButton), for: .touchUpInside)
            let rightBarButton = UIBarButtonItem()
            rightBarButton.customView = btnHelp
            
            self.navigationItem.rightBarButtonItem = rightBarButton
        }
    }
    
    @objc func tappedAtLeftButton(sender:UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func tappedAtRightButton(sender:UIButton) {
        
    }
    
}
extension UIViewController {
    func pushToLockScreenViewController(delegate:LockScreenViewControllerDelegate, passCode: String = "", mnemonic: String = "", isCreateAccount: Bool, isDisablePass: Bool = false, isAddAccount:Bool = false) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "lockScreenViewController") as? LockScreenViewController
        vc?.delegate = delegate
        vc?.passCode = passCode
        vc?.mnemonic = mnemonic
        vc?.isEnableBackButton = true
        vc?.isCreateAccount = isCreateAccount
        vc?.isDisablePassCode = isDisablePass
        vc?.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    func pushChooseSignersViewController() {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "chooseSignersViewController") as? ChooseSignersViewController
        vc?.hidesBottomBarWhenPushed = true
        navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func pushBackUpViewController(isAddAccount:Bool = false) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "backUpViewController") as? BackUpViewController
        vc?.hidesBottomBarWhenPushed = true
        vc?.isAddAcount = isAddAccount
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func pushRestoreAccountViewController(isAddAccount:Bool = false) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "restoreAccountViewController") as? RestoreAccountViewController
        vc?.hidesBottomBarWhenPushed = true
        vc?.isAddAcount = isAddAccount
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    func pushMnemonicGenerationViewController(isAddAccount:Bool = false) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "mnemonicGenerationViewController") as? MnemonicGenerationViewController
        vc?.hidesBottomBarWhenPushed = true
        vc?.isAddAcount = isAddAccount
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func pushMnemonicVerificationViewController(mnemoricList:[String] = [],isAddAccount:Bool = false ) {
        
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "mnemonicVerificationViewController") as? MnemonicVerificationViewController
        vc?.mnemoricList = mnemoricList
        vc?.isAddAcount = isAddAccount
        vc?.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func pushMainTabbarViewController() {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "mainTabbarViewController") as? MainTabbarViewController
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func presentToLockScreenViewController(delegate:LockScreenViewControllerDelegate) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "lockScreenViewController") as? LockScreenViewController
        vc?.delegate = delegate
        vc?.hidesBottomBarWhenPushed = true
        vc?.isEnableBackButton = false
        if #available(iOS 13.0, *) {
            vc?.modalPresentationStyle = .fullScreen
        }
        self.present(vc!, animated: true, completion: nil)
    }

    
    func exitAppAndRequestReopenNotify(content: String) {
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Touch reopen app".localizedString()
        notificationContent.body = "\(content)"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.4, repeats: false)
        let request = UNNotificationRequest(identifier: "1", content: notificationContent, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("\(error.localizedDescription)")
            } else {
                exit(0);
            }
            
        }
    }

}
