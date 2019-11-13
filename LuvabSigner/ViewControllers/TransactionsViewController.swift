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
     
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Transaction List".localizedString()
        btnBack?.isHidden = true
        Broadcaster.register(bSignersNotificationOpenedDelegate.self, observer: self)
        if let loadedData = KeychainWrapper.standard.data(forKey: "SIGNATURE") {

            if let signatureModel = NSKeyedUnarchiver.unarchiveObject(with: loadedData) as? [SignatureModel] {
                for signature in signatureModel {
                    listSignature.append(signature.publicKey!)
                }
            }
        }
        bSignerServiceManager.sharedInstance.taskGetTransactionList(publicKeys: listSignature, userId: bSignerServiceManager.sharedInstance.oneSignalUserId).continueOnSuccessWith(continuation: { task in
            self.listTransaction = task as! [TransactionModel]
            self.tableView.reloadData()
        }).continueOnErrorWith(continuation: { error in
            self.showAlertWithText(text: "Some thing went wrong")
        })
        tableView.separatorStyle = .none
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }


    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

}

extension TransactionsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listTransaction.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "transactionTableViewCell", for: indexPath) as! TransactionTableViewCell
        cell.lblName.text = "Name: " + listTransaction[indexPath.row].name
        //cell.lblPublicKey.text = listTransaction[indexPath.row].publicKey
        cell.lblDateTime.text = ""
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        pushTransactionDetailsViewController(model: listTransaction[indexPath.row])
    }
}

extension TransactionsViewController: bSignersNotificationOpenedDelegate {
    func notifySignTransaction(model: TransactionModel) {
    }
    
    func notifyHostTransaction() {
    }
    
    func notifyApproveTransaction(model: TransactionModel) {
        pushChooseSignersViewController(model: model)
    }
    
    func notifyChooseSigners() {
        self.pushChooseSignersViewController()
    }
}
