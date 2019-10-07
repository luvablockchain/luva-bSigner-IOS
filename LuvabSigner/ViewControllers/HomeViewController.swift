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

class HomeViewController: UIViewController {
    
    @IBOutlet weak var btnAdd: UIButton!
    
    @IBOutlet weak var btnEdit: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    var shouldShowLockScreen = true
    
    var timeBackGround:Date?
    
    var listKey:[String] = []

    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnAdd.setImage(UIImage(named: "ic_plus")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        btnAdd.tintColor = BaseViewController.MainColor
        btnAdd.setTitle(" " + "Add signature".localizedString(), for: .normal)
        btnAdd.isHidden = true
        if ConfigModel.sharedInstance.enablePassCode == .on {
            presentToLockScreenViewController(delegate: self)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification
            , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification
            , object: nil)
        
        if let publicKey =  KeychainWrapper.standard.string(forKey: "PUBLICKEY") {
            listKey.append(publicKey)
        }
        tableView.separatorStyle = .none
        tableView.register(SignatureTableViewCell.nib, forCellReuseIdentifier: SignatureTableViewCell.key)
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

    
    @IBAction func tappedEditAccount(_ sender: Any) {
        btnEdit.isSelected = !btnEdit.isSelected
        if btnEdit.isSelected {
            tableView.reloadData()
            btnAdd.isHidden = false
            btnEdit.setImage(UIImage(named: "ic_success-1"), for: .normal)
        } else {
            tableView.reloadData()
            btnAdd.isHidden = true
            btnEdit.setImage(UIImage(named: "ic_enableEdit"), for: .normal)
        }
    }
    
    @IBAction func tappedAddSignature(_ sender: Any) {
        if let mnemonic = KeychainWrapper.standard.string(forKey: "MNEMONIC") {
            HUD.show(.labeledProgress(title: nil, subtitle: "Loading..."))
            DispatchQueue.global(qos: .background).async {
                self.index = self.index + 1
                let publickey = MnemonicHelper.getKeyPairFrom(mnemonic, index: self.index).accountId
                DispatchQueue.main.async {
                    if publickey != ""
                    {
                        self.listKey.append(publickey)
                        self.tableView.reloadData()
                        HUD.hide()
                    }
                }
            }
        }

    }
}
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listKey.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if btnEdit.isSelected {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: SignatureTableViewCell.key) as! SignatureTableViewCell
            cell.lblPublicKey.text = listKey[indexPath.row]
            cell.txtTitle.text = "Signature " + "\(indexPath.row)"
            return cell
        } else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "homeTableViewCell") as! HomeTableViewCell
            cell.lblPublicKey.text = listKey[indexPath.row]
            cell.lblTitle.text = "Signature " + "\(indexPath.row)"
            return cell
        }
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
