//
//  BaseViewController.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 9/20/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController,UIGestureRecognizerDelegate {
    
    static let MainColor = UIColor.init(rgb: 0x70b500)
    
    var btnBack:UIButton?
    
    private var alertView: UIView!
    
    private var textLabel: UILabel!


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
        }
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    @objc func tappedAtLeftButton(sender:UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
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
              self.removeAlertText()
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
    
    func pushChooseSignersViewController(model:TransactionModel? = nil) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "chooseSignersViewController") as? ChooseSignersViewController
        vc?.hidesBottomBarWhenPushed = true
        vc?.model = model
        navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func pushTransactionInfoViewController(signer:SignatureModel, model:TransactionModel) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "transactionInfoViewController") as? TransactionInfoViewController
        vc?.hidesBottomBarWhenPushed = true
        vc?.model = model
        navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func pushTransactionDetailsViewController(model:TransactionModel? = nil) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "transactionDetailsViewController") as? TransactionDetailsViewController
        vc?.hidesBottomBarWhenPushed = true
        vc?.model = model
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
    
    func pushMnemonicVerificationViewController(mnemoricList:[String] = [],isAddAccount:Bool = false) {
        
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "mnemonicVerificationViewController") as? MnemonicVerificationViewController
        vc?.mnemoricList = mnemoricList
        vc?.isAddAcount = isAddAccount
        vc?.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func pushMainTabbarViewController(selectedIndex: Int = 0) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "mainTabbarViewController") as? MainTabbarViewController
        vc?.selectedIndex = selectedIndex
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func pushSignUpViewController() {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "signUpViewController") as? SignUpViewController
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
