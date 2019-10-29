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

struct SignModel {
    var title:[String]
    var publicKey:[String]
}

class HomeViewController: UIViewController {
    
    
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
    
    var btnRestore:UIButton!
    
    var btnCreate:UIButton!
    
    var stackView:UIStackView!
    
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
        if let loadedData = UserDefaults().data(forKey: "SIGNNATURE") {

            if let signatureModel = NSKeyedUnarchiver.unarchiveObject(with: loadedData) as? [SignatureModel] {
                self.model = signatureModel
            }
        }

        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        btnCreate = UIButton.init(frame: .zero)
        btnRestore = UIButton.init(frame: .zero)
        btnRestore.translatesAutoresizingMaskIntoConstraints = false
        btnCreate.translatesAutoresizingMaskIntoConstraints = false
        stackView = UIStackView.init(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        stackView.addArrangedSubview(btnCreate)
        stackView.addArrangedSubview(btnRestore)
        btnCreate.setTitle("Add Signature".localizedString(), for: .normal)
        btnCreate.addTarget(self, action: #selector(tappedCreateAccount), for: .touchUpInside)
        btnCreate.backgroundColor = BaseViewController.MainColor
        btnCreate.layer.cornerRadius = 20
        btnCreate.setTitleColor(.white, for: .normal)
        btnRestore.setTitle("Restore Signature".localizedString(), for: .normal)
        btnRestore.addTarget(self, action: #selector(tappedRestoreAccount), for: .touchUpInside)
        btnRestore.backgroundColor = BaseViewController.MainColor
        btnRestore.layer.cornerRadius = 20
        btnRestore.setTitleColor(.white, for: .normal)
        btnRestore.titleLabel!.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        btnCreate.titleLabel!.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        customView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: customView.leadingAnchor,constant: 20
            ),
            stackView.bottomAnchor.constraint(equalTo: customView.bottomAnchor,constant: -5),
            stackView.topAnchor.constraint(equalTo: customView.topAnchor,constant: 5),
            stackView.trailingAnchor.constraint(equalTo: customView.trailingAnchor,constant: -20)
        ])

        tableView.tableHeaderView = customView
        tableView.separatorStyle = .none
        UserDefaultsHelper.accountStatus = .waitingToBecomeSinger
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @objc func tappedRestoreAccount (){
        self.pushRestoreAccountViewController(isAddAccount: true)
    }
    
    @objc func tappedCreateAccount () {
        self.pushBackUpViewController(isAddAccount: true)
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
                self.model.remove(at: index)
                let data = NSKeyedArchiver.archivedData(withRootObject: self.model)
                UserDefaults().set(data, forKey: "SIGNNATURE")
                self.tableView.reloadData()
            }
        }
    }
    
}

extension HomeViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        model[indexEdit].title = textField.text!
        let data = NSKeyedArchiver.archivedData(withRootObject: model)
        UserDefaults().set(data, forKey: "SIGNNATURE")
        tableView.reloadData()
    }
}

extension HomeViewController: bSignersNotificationOpenedDelegate {
    func notifyApproveTransaction(model: TransactionModel) {
        pushChooseSignersViewController(model: model)
    }
    
    func notifyChooseSigners() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.pushChooseSignersViewController()
        }
    }
}
