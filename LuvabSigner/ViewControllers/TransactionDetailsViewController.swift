//
//  TransactionDetailsViewController.swift
//  bSigner
//
//  Created by Nguyen Xuan Khang on 11/5/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit
import stellarsdk
import SwiftKeychainWrapper
import EZAlertController
import PKHUD

class TransactionDetailsViewController: BaseViewController {

    @IBOutlet weak var lblWeight: UILabel!
    @IBOutlet weak var lblTitleWeight: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var lblFrom: UILabel!
    
    @IBOutlet weak var lblFromKey: UILabel!
    
    @IBOutlet weak var lblTo: UILabel!
    
    @IBOutlet weak var lblToKey: UILabel!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lblNote: UILabel!
    
    @IBOutlet weak var lblMemo: UILabel!
    
    @IBOutlet weak var lblAmounts: UILabel!
    
    @IBOutlet weak var lblAmount: UILabel!
    
    var model:TransactionModel!
    
    var listSignature:[SignatureModel] = []
        
    var keyPairToSign:KeyPair!
    
    var listSigner:[SignatureModel] = []
    
    var outputXdrEncodedEnvelope: String?
    
    var checkSignature = false
    
    var arraySignature:[String] = []
    
    var sourceAccount: String = ""
    
    var destination: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Transaction Details".localizedString()
        lblAmount.text = "Luva Number".localizedString()
        lblMemo.text = "Memo".localizedString()
        lblTitle.text = "Signature list".localizedString()
        self.lblFrom.text = "Loading".localizedString() + "..."
        self.lblTo.text = "Loading".localizedString() + "..."
        self.lblTitleWeight.text = "Threshold".localizedString()
        self.lblWeight.text = String(model.med_threshold)
        Broadcaster.register(bSignersNotificationOpenedDelegate.self, observer: self)
        if let loadedData = KeychainWrapper.standard.data(forKey: "SIGNATURE") {

            if let signnatureModel = NSKeyedUnarchiver.unarchiveObject(with: loadedData) as? [SignatureModel] {
                self.listSigner = signnatureModel
                for signature in listSigner {
                    arraySignature.append(signature.publicKey!)
                }
            }
        }
        
        for signature in model.listSignature {
            let model = SignatureModel(json: signature)
            listSignature.append(model)
        }
        
        tableView.separatorStyle = .none
        do {
            let envelope = try TransactionEnvelopeXDR(xdr:model.xdr)
            let operationXDR = envelope.tx.operations[0]
            let operation = try Operation.fromXDR(operationXDR:operationXDR)
            let paymentOperation = operation as! PaymentOperation
            lblFromKey.text = envelope.tx.sourceAccount.accountId
            lblToKey.text = paymentOperation.destination.accountId
            self.sourceAccount = envelope.tx.sourceAccount.accountId
            self.destination = paymentOperation.destination.accountId
            let newAmounts = paymentOperation.amount.formattedAmount!.split(".").first ?? ""
            let attLuva = NSAttributedString.init(string: "LUVA" ,
                                                  attributes:[NSAttributedString.Key.baselineOffset: 5,NSAttributedString.Key.font:UIFont.systemFont(ofSize: 10)])
            let attMoney = NSMutableAttributedString(string: newAmounts.currencyVND)
            lblAmounts.attributedText = attMoney + attLuva
            lblNote.text = ""
        } catch {
            print("Invalid xdr string")
        }
        bSignerServiceManager.sharedInstance.isSeenDetails = true
        bSignerServiceManager.sharedInstance.taskGetFederation(publicKey: self.sourceAccount, type: "id").continueOnSuccessWith(continuation: { task in
            let federation = task as! String
            self.lblFrom.text = "From".localizedString() + ": " + federation
            bSignerServiceManager.sharedInstance.taskGetFederation(publicKey: self.destination, type: "id").continueOnSuccessWith(continuation: { task in
                let federation = task as! String
                self.lblTo.text = "To".localizedString() + ": " + federation
            }).continueOnErrorWith(continuation: { error in
                self.lblFrom.text = "From".localizedString() + ":"
            })
            
        }).continueOnErrorWith(continuation: { error in
            self.lblTo.text = "To".localizedString() + ":"
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bSignerServiceManager.sharedInstance.isSeenDetails = false
    }
    
}

extension TransactionDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listSignature.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "detailTransactionTableViewCell", for: indexPath) as! DetailTransactionTableViewCell
        cell.delegate = self
        cell.lblSignature.text = "Signature".localizedString() + ": " + listSignature[indexPath.row].public_key
        cell.btnSignTransaction.tag = indexPath.row
        cell.lblWeight.text = "Weight".localizedString() + ": " + String(listSignature[indexPath.row].weight)
        for signature in listSigner {
            if signature.publicKey == listSignature[indexPath.row].public_key {
                if listSignature[indexPath.row].signed == true {
                    cell.lblStatus.text = "Signed".localizedString()
                    cell.imgStatus.image = UIImage.init(named: "ic_success-1")
                    let date = Int(listSignature[indexPath.row].signed_at).dateFromTimeInterval
                    cell.lblTime.text = "Signing time".localizedString() + ": " + date.shortDateTime
                    cell.btnSignTransaction.isEnabled = false
                    cell.btnSignTransaction.backgroundColor = .lightGray
                } else {
                    cell.lblStatus.text = "Not signed".localizedString()
                    cell.imgStatus.image = UIImage.init(named: "ic_uncheck")
                    cell.lblTime.text = "Signing time".localizedString() + ": "
                    cell.btnSignTransaction.isEnabled = true
                    cell.btnSignTransaction.backgroundColor = BaseViewController.MainColor
                }
            } else {
                if listSignature[indexPath.row].signed == true {
                     cell.lblStatus.text = "Signed".localizedString()
                     cell.imgStatus.image = UIImage.init(named: "ic_success-1")
                     let date = Int(listSignature[indexPath.row].signed_at).dateFromTimeInterval
                     cell.lblTime.text = "Signing time".localizedString() + ": " + date.shortDateTime
                 } else {
                     cell.lblStatus.text = "Not signed".localizedString()
                     cell.imgStatus.image = UIImage.init(named: "ic_uncheck")
                     cell.lblTime.text = "Signing time".localizedString() + ": "
                 }
                cell.btnSignTransaction.isEnabled = false
                cell.btnSignTransaction.backgroundColor = .lightGray
            }
        }
        return cell
    }
}

extension TransactionDetailsViewController: DetailTransactionTableViewCellDelegate {
    func didSignTransaction(index: Int) {
        HUD.show(.labeledProgress(title: nil, subtitle: "Please wait..."))
        var indexSigner = 0
        for signer in listSigner {
            if signer.publicKey == listSignature[index].public_key {
                checkSignature = true
                break;
            }
            indexSigner += 1
        }
        if checkSignature {
            keyPairToSign = MnemonicHelper.getKeyPairFrom(listSigner[indexSigner].mnemonic!)
            do {
                let envelope = try TransactionEnvelopeXDR(xdr:model.xdr)
                let transactionHash =  try [UInt8](envelope.tx.hash(network: .testnet))
                let userSignature = keyPairToSign.signDecorated(transactionHash)
                let signatures = userSignature.signature
                let signature = signatures.base64EncodedString(options: NSData.Base64EncodingOptions())
                bSignerServiceManager.sharedInstance.taskGetSignTransaction(userId: bSignerServiceManager.sharedInstance.oneSignalUserId, xdr: model.xdr, publicKey: listSignature[index].public_key, signature:signature).continueOnSuccessWith(continuation: { task in
                    let model = task as! [SignatureModel]
                    if model.count > 0 {
                        HUD.hide()
                        EZAlertController.alert("", message: "Some thing when wrong".localizedString() + ". " + "Please try again".localizedString() + ".", acceptMessage: "OK") {
                            self.dismiss(animated: true, completion: nil)
                        }
                    } else {
                        bSignerServiceManager.sharedInstance.taskGetTransactionList(publicKeys: self.arraySignature, userId: bSignerServiceManager.sharedInstance.oneSignalUserId).continueOnSuccessWith(continuation: { task in
                            HUD.hide()
                            let listTransaction = task as! [TransactionModel]
                            for model in listTransaction {
                                if model.xdr == self.model.xdr {
                                    var newSignature:[SignatureModel] = []
                                    for signature in model.listSignature {
                                        let model = SignatureModel(json: signature)
                                        newSignature.append(model)
                                    }
                                    self.listSignature = newSignature
                                }
                            }
                            self.tableView.reloadData()
                        }).continueOnErrorWith(continuation: { error in
                            HUD.hide()
                            self.showAlertWithText(text: "Some thing went wrong".localizedString() + ". " + "Please try again".localizedString() + ".")
                        })
                    }
                }).continueOnErrorWith(continuation: { error in
                    HUD.hide()
                    self.showAlertWithText(text: "Some thing went wrong".localizedString() + ". " + "Please try again".localizedString() + ".")
                })
            } catch {
                HUD.hide()
                print("Invalid xdr string")
            }
        } else {
            HUD.hide()
            EZAlertController.alert("", message: "This signature is not on the device".localizedString() + ".", acceptMessage: "OK".localizedString()) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

extension TransactionDetailsViewController: bSignersNotificationOpenedDelegate {
    func notifySignTransaction(model: TransactionModel, isOpen: Bool) {
        if !isOpen {
            bSignerServiceManager.sharedInstance.taskGetTransactionList(publicKeys: self.arraySignature, userId: bSignerServiceManager.sharedInstance.oneSignalUserId).continueOnSuccessWith(continuation: { task in
                HUD.hide()
                let listTransaction = task as! [TransactionModel]
                for model in listTransaction {
                    if model.xdr == self.model.xdr {
                        var newSignature:[SignatureModel] = []
                        for signature in model.listSignature {
                            let model = SignatureModel(json: signature)
                            newSignature.append(model)
                        }
                        self.listSignature = newSignature
                    }
                }
                self.tableView.reloadData()
            }).continueOnErrorWith(continuation: { error in
                HUD.hide()
                self.showAlertWithText(text: "Some thing went wrong".localizedString() + ". " + "Please try again".localizedString() + ".")
            })
        }
    }
    
    func notifyHostTransaction(isOpen: Bool) {
        if isOpen {
            pushMainTabbarViewController(selectedIndex: 1)
        }
    }
        
    func notifyApproveTransaction(model: TransactionModel) {
    }
    
    func notifyChooseSigners() {
    }
}
