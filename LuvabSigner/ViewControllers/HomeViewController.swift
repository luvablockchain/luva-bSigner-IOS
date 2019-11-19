//
//  HomeViewController.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 10/7/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SwiftKeychainWrapper
import PKHUD
import EZAlertController
import stellarsdk
import OneSignal

struct SignModel {
    var title:[String]
    var publicKey:[String]
}

class HomeViewController: BaseViewController {
    
    
    @IBOutlet weak var btnRestoreSignature: UIButton!
    
    @IBOutlet weak var btnAddSignature: UIButton!
    
    @IBOutlet weak var btnEdit: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
        
    
    @IBOutlet weak var lblTitle: UILabel!
    
    var shouldShowLockScreen = true
    
    var timeBackGround:Date?
    
    var listKey:[String] = []

    var index = 0
    
    var indexEdit = 0
    
    var sections:[SignModel] = []
    
    var model:[SignatureModel] = []
    
    var amountNumber: NSNumber = NSNumber(value: 0.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        ConfigModel.sharedInstance.loadLocalized()
        lblTitle.text = "Your signers".localizedString()
        if ConfigModel.sharedInstance.enablePassCode == .on &&         ConfigModel.sharedInstance.accountType == .normal{
            presentToLockScreenViewController(delegate: self)
        }
        Broadcaster.register(bSignersNotificationOpenedDelegate.self, observer: self)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification
            , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification
            , object: nil)
        if let loadedData = KeychainWrapper.standard.data(forKey: "SIGNATURE") {

            if let signatureModel = NSKeyedUnarchiver.unarchiveObject(with: loadedData) as? [SignatureModel] {
                self.model = signatureModel
            }
        }
        btnAddSignature.layer.cornerRadius = 20
        btnAddSignature.setTitle("Add Signature".localizedString(), for: .normal)
        btnRestoreSignature.layer.cornerRadius = 20
        btnRestoreSignature.setTitle("Restore Signature".localizedString(), for: .normal)
        tableView.separatorStyle = .none
        UserDefaultsHelper.accountStatus = .waitingToBecomeSinger
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
        
    @objc func willEnterForeground() {
        let currentDate = Date()
        if let time = timeBackGround {
            let timeInterval  =  currentDate.timeIntervalSince1970 - time.timeIntervalSince1970
            if Int(timeInterval) < ConfigModel.sharedInstance.configType.second {
                shouldShowLockScreen = false
            }
        }
    }
    
    @objc func didEnterBackground() {
        if ConfigModel.sharedInstance.enablePassCode == .on {
            ConfigModel.sharedInstance.accountType = .normal
            ConfigModel.sharedInstance.saveConfigToDB()
            self.timeBackGround = Date()
            let second = ConfigModel.sharedInstance.configType.second
            shouldShowLockScreen = true
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(second)) {
                if self.shouldShowLockScreen {
                    self.presentLockScreen()
                }
            }
        }
    }
    
    func presentLockScreen() {
        if let topViewController = UIApplication.topViewController() {
            topViewController.presentToLockScreenViewController(delegate: self)
        }
    }
    
    @IBAction func tappedRestoreSignature(_ sender: Any) {
        self.pushRestoreAccountViewController(isAddAccount: true)
    }
    
    @IBAction func tappedAddSignature(_ sender: Any) {
        self.pushBackUpViewController(isAddAccount: true)
    }
    
    @IBAction func tappedEditAccount(_ sender: Any) {
        btnEdit.isSelected = !btnEdit.isSelected
        if btnEdit.isSelected {
            tableView.reloadData()
            btnEdit.setImage(UIImage(named: "ic_success-1"), for: .normal)
        } else {
            btnEdit.setImage(UIImage(named: "ic_enableEdit"), for: .normal)
            tableView.reloadData()
        }
    }
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "homeTableViewCell") as! HomeTableViewCell
        cell.delegate = self
        cell.lblPublicKey.text = model[indexPath.row].publicKey
        cell.lblTitle.text = model[indexPath.row].title
        cell.txtTitle.text = model[indexPath.row].title
        cell.btnEdit.tag = indexPath.row
        cell.btnDelete.tag = indexPath.row
        if btnEdit.isSelected {
            cell.viewEdit.isUserInteractionEnabled = false
            cell.btnDelete.isHidden = false
            cell.btnEdit.isHidden = false
        } else {
            cell.viewEdit.isUserInteractionEnabled = true
            cell.txtTitle.isHidden = true
            cell.lblTitle.isHidden = false
            cell.btnDelete.isHidden = true
            cell.btnEdit.isHidden = true
        }
        return cell
    }
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "publicKeyViewController") as? PublicKeyViewController
            vc?.model = model[indexPath.row]
            vc?.hidesBottomBarWhenPushed = true
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.navigationController?.pushViewController(vc!, animated: true)

        }
    
}

extension HomeViewController: LockScreenViewControllerDelegate {
    
    func didChangePassCode() {
        
    }
    
    func didConfirmPassCodeSuccess() {
        dismiss(animated: true, completion: nil)
    }
    
    func didInPutPassCodeSuccess(_ pass: String) {
        
    }
    
    func didConfirmPassCode() {
        
    }
    
    func didPopViewController() {
        
    }
    
    func didDisablePassCodeSuccess() {
        
    }
}

extension HomeViewController: HomeTableViewCellDelegate {
    
    func didEditTitleSignature(index: Int) {
        self.indexEdit = index
    }
    
    func didDeleteSignature(index: Int) {
        EZAlertController.alert("Are you sure".localizedString() + "?", message:"This action cannot revert".localizedString() + ", " + "Continue to delete this account".localizedString() + "?", buttons: ["Cancel".localizedString(), "OK".localizedString()]) { (alertAction, position) -> Void in
            if position == 0 {
                self.dismiss(animated: true, completion: nil)
            } else if position == 1 {
                 HUD.show(.labeledProgress(title: nil, subtitle: "Loading..."))
                bSignerServiceManager.sharedInstance.taskGetUnSubscribeSignature(userId: bSignerServiceManager.sharedInstance.oneSignalUserId, publicKey: self.model[index].publicKey!).continueOnSuccessWith(continuation: { task in
                    self.model.remove(at: index)
                    let data = NSKeyedArchiver.archivedData(withRootObject: self.model)
                    KeychainWrapper.standard.set(data, forKey: "SIGNATURE")
                    self.tableView.reloadData()
                    HUD.hide()
                    self.showAlertWithText(text: "Remove signature success".localizedString())
                }).continueOnErrorWith(continuation: { error in
                    HUD.hide()
                    self.showAlertWithText(text: "Some thing went wrong".localizedString() + ". " + "Please try again".localizedString() + ".")
                })
            }
        }
    }
    
}

extension HomeViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        model[indexEdit].title = textField.text!
        let data = NSKeyedArchiver.archivedData(withRootObject: model)
        KeychainWrapper.standard.set(data, forKey: "SIGNATURE")
        tableView.reloadData()
    }
}

extension HomeViewController: bSignersNotificationOpenedDelegate {
    func notifySignTransaction(model: TransactionModel, isOpen: Bool) {
        if isOpen && bSignerServiceManager.sharedInstance.isSeenDetails == false {
            pushTransactionDetailsViewController(model: model)
        }
    }
    
    func notifyHostTransaction(isOpen: Bool) {
        if isOpen {
            tabBarController?.selectedIndex = 1
        }
    }
    
    func notifyApproveTransaction(model: TransactionModel) {
        pushChooseSignersViewController(model: model)
    }
    
    func notifyChooseSigners() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.pushChooseSignersViewController()
        }
    }
}
