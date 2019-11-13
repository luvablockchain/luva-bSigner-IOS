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

class TransactionDetailsViewController: BaseViewController {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Transaction Details".localizedString()
        lblFrom.text = "From:".localizedString()
        lblTo.text = "To:".localizedString()
        lblAmount.text = "Amount".localizedString()
        lblMemo.text = "Memo".localizedString()
        lblTitle.text = "Signature list".localizedString()
        
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
            let newAmounts = paymentOperation.amount.formattedAmount!.split(".").first ?? ""
            lblAmounts.text = newAmounts.currencyVND
            lblNote.text = envelope.tx.memo.xdrEncoded
        } catch {
            print("Invalid xdr string")
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
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
        if listSignature[indexPath.row].signed == true {
            cell.lblStatus.text = "Đã ký"
            cell.imgStatus.image = UIImage.init(named: "ic_success-1")
            let date = Int(listSignature[indexPath.row].signed_at).dateFromTimeInterval
            cell.lblTime.text = "Signing time".localizedString() + ": " + date.shortDateTime
            cell.btnSignTransaction.isEnabled = false
            cell.btnSignTransaction.backgroundColor = .lightGray
        } else {
            cell.lblStatus.text = "Chưa ký"
            cell.imgStatus.image = UIImage.init(named: "ic_uncheck")
            cell.lblTime.text = "Signing time".localizedString() + ": "
            cell.btnSignTransaction.isEnabled = true
            cell.btnSignTransaction.backgroundColor = BaseViewController.MainColor
        }
        return cell
    }
}

extension TransactionDetailsViewController: DetailTransactionTableViewCellDelegate {
    func didSignTransaction(index: Int) {
        var indexSigner = 0
        for signer in listSigner {
            if signer.public_key == listSignature[index].public_key {
                checkSignature = true
                break;
            }
            indexSigner += 1
        }
        if checkSignature {
            keyPairToSign = MnemonicHelper.getKeyPairFrom(listSigner[indexSigner - 1].mnemonic!)
            do {
                let envelope = try TransactionEnvelopeXDR(xdr:model.xdr)
                let transactionHash =  try [UInt8](envelope.tx.hash(network: .testnet))
                let userSignature = keyPairToSign.signDecorated(transactionHash)
                let signatures = userSignature.signature
                let signature = signatures.base64EncodedString(options: NSData.Base64EncodingOptions())
                bSignerServiceManager.sharedInstance.taskGetSignTransaction(userId: bSignerServiceManager.sharedInstance.oneSignalUserId, xdr: model.xdr, publicKey: listSignature[index].public_key, signature:signature).continueOnSuccessWith(continuation: { task in
                    let model = task as! [SignatureModel]
                    if model.count > 0 {
                        
                    } else {
                        bSignerServiceManager.sharedInstance.taskGetTransactionList(publicKeys: self.arraySignature, userId: bSignerServiceManager.sharedInstance.oneSignalUserId).continueOnSuccessWith(continuation: { task in
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
                            self.showAlertWithText(text: "Some thing went wrong")
                        })

                    }
                }).continueOnErrorWith(continuation: { error in
                    self.showAlertWithText(text: "Some thing went wrong")
                })
            } catch {
                print("Invalid xdr string")
            }
        } else {
            EZAlertController.alert("", message: "This signature is not on the device".localizedString() + ".", acceptMessage: "OK".localizedString()) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
