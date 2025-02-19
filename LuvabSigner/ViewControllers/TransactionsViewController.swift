//
//  TransactionsViewController.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 10/7/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import PKHUD
import SwiftKeychainWrapper
import SwiftyJSON

class TransactionsViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
        
    var listTransaction:[TransactionModel] = []
    
    var listSignature:[String] = []
    
    var shouldShowLockScreen = true
    
    var timeBackGround:Date?
    
    var arrSignature:[SignatureModel] = []

    var btnRight:UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Transaction List".localizedString()
        btnBack?.isHidden = true
        if let _ = navigationController {
            btnRight = UIButton.init(type: .system)
            if #available(iOS 11.0, *) {
                btnRight?.contentHorizontalAlignment = .trailing
            }
            btnRight!.setImage(UIImage(named: "ic_reload")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
            btnRight!.tintColor = BaseViewController.MainColor
            btnRight!.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            btnRight!.addTarget(self, action:#selector(tappedAtRightButton), for: .touchUpInside)
            let rightBarButton = UIBarButtonItem()
            rightBarButton.customView = btnRight
            self.navigationItem.rightBarButtonItem = rightBarButton
        }
        Broadcaster.register(bSignersNotificationOpenedDelegate.self, observer: self)
        if let loadedData = KeychainWrapper.standard.data(forKey: "SIGNATURE") {

            if let signatureModel = NSKeyedUnarchiver.unarchiveObject(with: loadedData) as? [SignatureModel] {
                for signature in signatureModel {
                    listSignature.append(signature.publicKey!)
                }
            }
        }
        HUD.show(.labeledProgress(title: nil, subtitle: "Loading..."))
        bSignerServiceManager.sharedInstance.taskGetTransactionList(publicKeys: listSignature, userId: bSignerServiceManager.sharedInstance.oneSignalUserId).continueOnSuccessWith(continuation: { task in
            HUD.hide()
            self.listTransaction = task as! [TransactionModel]
            self.listTransaction = self.listTransaction.sorted(by: { (first, second) -> Bool in
                let timeSecond = Int(second.hosted_at).dateFromTimeInterval
                let timeFirst = Int(first.hosted_at).dateFromTimeInterval
                return timeSecond.isEarly(timeFirst)
            })
            self.tableView.reloadData()
        }).continueOnErrorWith(continuation: { error in
            HUD.hide()
            self.showAlertWithText(text: "Some thing went wrong".localizedString() + ". " + "Please try again".localizedString() + ".")
        })
        tableView.separatorStyle = .none
        bSignerServiceManager.sharedInstance.isSeenTransactions = true
    }
    
    @objc func tappedAtRightButton(sender:UIButton) {
        HUD.show(.labeledProgress(title: nil, subtitle: "Loading..."))
        bSignerServiceManager.sharedInstance.taskGetTransactionList(publicKeys: listSignature, userId: bSignerServiceManager.sharedInstance.oneSignalUserId).continueOnSuccessWith(continuation: { task in
            HUD.hide()
            self.listTransaction = task as! [TransactionModel]
            self.listTransaction = self.listTransaction.sorted(by: { (first, second) -> Bool in
                let timeSecond = Int(second.hosted_at).dateFromTimeInterval
                let timeFirst = Int(first.hosted_at).dateFromTimeInterval
                return timeSecond.isEarly(timeFirst)
            })
            self.tableView.reloadData()
        }).continueOnErrorWith(continuation: { error in
            HUD.hide()
            self.showAlertWithText(text: "Some thing went wrong".localizedString() + ". " + "Please try again".localizedString() + ".")
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bSignerServiceManager.sharedInstance.isSeenTransactions = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    @IBAction func tappedReloadData(_ sender: Any) {

    }
}

extension TransactionsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listTransaction.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "transactionTableViewCell", for: indexPath) as! TransactionTableViewCell
        cell.lblName.text = "Name".localizedString() + ": " + listTransaction[indexPath.row].name
        for signature in self.listTransaction[indexPath.row].listSignature {
            let model = SignatureModel(json: signature)
            arrSignature.append(model)
        }
        for signed in arrSignature {
            if signed.signed {
                cell.lblStatus.text = "Status".localizedString() + ": " + "Completed".localizedString()
            } else {
                cell.lblStatus.text = "Status".localizedString() + ": " + "Processing".localizedString()
            }
        }
        let time = Int(listTransaction[indexPath.row].hosted_at).dateFromTimeInterval
        cell.lblDateTime.text = "Time".localizedString() + ": " + time.shortDateTime
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        pushTransactionDetailsViewController(model: listTransaction[indexPath.row])
    }
}

extension TransactionsViewController: bSignersNotificationOpenedDelegate {
    
    func notifySignTransaction(model: TransactionModel, isOpen: Bool) {
        if isOpen && bSignerServiceManager.sharedInstance.isSeenDetails == false {
            pushTransactionDetailsViewController(model: model)
        }
    }
    
    func notifyHostTransaction(isOpen: Bool) {
        self.listTransaction.removeAll()
        bSignerServiceManager.sharedInstance.taskGetTransactionList(publicKeys: listSignature, userId: bSignerServiceManager.sharedInstance.oneSignalUserId).continueOnSuccessWith(continuation: { task in
            self.listTransaction = task as! [TransactionModel]
            self.listTransaction = self.listTransaction.sorted(by: { (first, second) -> Bool in
                let timeSecond = Int(second.hosted_at).dateFromTimeInterval
                let timeFirst = Int(first.hosted_at).dateFromTimeInterval
                return timeSecond.isEarly(timeFirst)
            })
            self.tableView.reloadData()
        }).continueOnErrorWith(continuation: { error in
            self.showAlertWithText(text: "Some thing went wrong".localizedString() + ". " + "Please try again".localizedString() + ".")
        })
    }

    func notifyApproveTransaction(model: TransactionModel) {
        pushChooseSignersViewController(model: model)
    }
    
    func notifyChooseSigners() {
        self.pushChooseSignersViewController()
    }
}
