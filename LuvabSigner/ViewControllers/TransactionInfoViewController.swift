//
//  TransactionInfoViewController.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 10/17/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit
import stellarsdk
import SwiftKeychainWrapper
import EZAlertController

class TransactionInfoViewController: UIViewController {
    
    @IBOutlet weak var lblWeight: UILabel!
    
    @IBOutlet weak var lblTitleWeight: UILabel!
    
    @IBOutlet weak var lblTransactions: UILabel!
    
    @IBOutlet weak var lblFrom: UILabel!
    
    @IBOutlet weak var viewTransaction: UIView!
        
    @IBOutlet weak var lblTo: UILabel!
    
    @IBOutlet weak var btnConfirm: UIButton!
    
    @IBOutlet weak var btnCancel: UIButton!
    
    @IBOutlet weak var lblSignnature: UILabel!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lblNote: UILabel!
    
    @IBOutlet weak var lblMemo: UILabel!
    
    @IBOutlet weak var lblMoney: UILabel!
    
    @IBOutlet weak var lblAmount: UILabel!
    
    @IBOutlet weak var lblToKey: UILabel!
    
    @IBOutlet weak var lblFromKey: UILabel!
    
    var model:TransactionModel!
        
    var keyPairToSign:KeyPair!
        
    var signature:String?
    
    var listSigner:[SignatureModel] = []
    
    var index = 0
    
    var checkSignature = false
    
    var sourceAccount: String = ""
    
    var destination: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTransactions.text = "Transaction Info".localizedString()
        lblFrom.text = "Loading...".localizedString()
        lblTo.text = "Loading...".localizedString()
        lblAmount.text = "Luva Number".localizedString()
        lblMemo.text = "Memo".localizedString()
        lblTitle.text = "Approve Transaction".localizedString()
        lblTitleWeight.text = "Weight".localizedString()
        lblWeight.text = ""
        btnCancel.setTitle("Cancel".localizedString(), for: .normal)
        btnCancel.layer.cornerRadius = 20
        btnConfirm.layer.cornerRadius = 20
        btnConfirm.setTitle("Approve".localizedString(), for: .normal)
        viewTransaction.layer.cornerRadius = 5
        viewTransaction.layer.borderWidth = 0.5
        viewTransaction.layer.borderColor = UIColor.lightGray.cgColor
        if let loadedData = KeychainWrapper.standard.data(forKey: "SIGNATURE") {

            if let signnatureModel = NSKeyedUnarchiver.unarchiveObject(with: loadedData) as? [SignatureModel] {
                self.listSigner = signnatureModel
            }
        }
  
        for signer in listSigner {
            if signer.publicKey == model.signers {
                self.checkSignature = true
                break;
            }
            index += 1
        }
        if checkSignature {
            lblSignnature.text = listSigner[index].publicKey
            keyPairToSign = MnemonicHelper.getKeyPairFrom(listSigner[index].mnemonic!)
            do {
                let envelope = try TransactionEnvelopeXDR(xdr:model.transactionXDR)
                let transactionHash =  try [UInt8](envelope.tx.hash(network: .testnet))
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
                lblMoney.attributedText = attMoney + attLuva
                lblNote.text = ""
                let decoratedSignature = keyPairToSign.signDecorated(transactionHash)
                let signatures = decoratedSignature.signature
                self.signature = signatures.base64EncodedString(options: NSData.Base64EncodingOptions())
            } catch {
                print("Invalid xdr string")
            }
        } else {
            lblSignnature.text = model.signers
            do {
                let envelope = try TransactionEnvelopeXDR(xdr:model.transactionXDR)
                let operationXDR = envelope.tx.operations[0]
                let operation = try Operation.fromXDR(operationXDR:operationXDR)
                let paymentOperation = operation as! PaymentOperation
                lblFromKey.text = envelope.tx.sourceAccount.accountId
                lblToKey.text = paymentOperation.destination.accountId
                let newAmounts = paymentOperation.amount.formattedAmount!.split(".").first ?? ""
                let attLuva = NSAttributedString.init(string: "LUVA" ,
                                                      attributes:[NSAttributedString.Key.baselineOffset: 5,NSAttributedString.Key.font:UIFont.systemFont(ofSize: 10)])
                let attMoney = NSMutableAttributedString(string: newAmounts.currencyVND)
                lblMoney.attributedText = attMoney + attLuva
                lblNote.text = ""
            } catch {
                print("Invalid xdr string")
            }

        }
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification
            , object: nil)
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
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
        
    @objc func didEnterBackground() {
        pushMainTabbarViewController()
    }

    @IBAction func tappedConfirmTransactions(_ sender: Any) {
        if checkSignature {
            let application = UIApplication.shared
            let luvaApp = "luvaapp://?signature=\(self.signature!)&transactionXDR=\(self.model.transactionXDR)&signerPublicKey=\(self.listSigner[index].publicKey!)"
            let appUrl = URL(string: luvaApp)!
            if application.canOpenURL(appUrl) {
                application.open(appUrl, options: [:], completionHandler: nil)
            }
        } else {
            EZAlertController.alert("", message: "This signature is not on the device".localizedString() + ".", acceptMessage: "OK".localizedString()) {
                let application = UIApplication.shared
                let luvaApp = "luvaapp://?signature=cancel"
                let appUrl = URL(string: luvaApp)!
                if application.canOpenURL(appUrl) {
                    application.open(appUrl, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    @IBAction func tappedCancelTransactions(_ sender: Any) {
        let application = UIApplication.shared
        let luvaApp = "luvaapp://?signature=cancel"
        let appUrl = URL(string: luvaApp)!
        if application.canOpenURL(appUrl) {
            application.open(appUrl, options: [:], completionHandler: nil)
        }
    }
}
