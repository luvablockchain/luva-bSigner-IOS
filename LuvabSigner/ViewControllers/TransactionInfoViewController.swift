//
//  TransactionInfoViewController.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 10/17/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit
import stellarsdk

class TransactionInfoViewController: UIViewController {
    
    @IBOutlet weak var lblTransactions: UILabel!
    
    @IBOutlet weak var lblFrom: UILabel!
    
    @IBOutlet weak var viewTransaction: UIView!
    
    @IBOutlet weak var lblName: UILabel!
    
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
    
    var signer:SignnatureModel!
    
    var keyPairToSign:KeyPair!
        
    var signature:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTransactions.text = "Transaction Info".localizedString()
        lblFrom.text = "From".localizedString()
        lblTo.text = "To".localizedString()
        lblAmount.text = "Amount".localizedString()
        lblMemo.text = "Memo".localizedString()
        lblTitle.text = "Approve Transaction".localizedString()
        btnCancel.setTitle("Cancel".localizedString(), for: .normal)
        btnCancel.layer.cornerRadius = 20
        btnConfirm.layer.cornerRadius = 20
        btnConfirm.setTitle("Approve".localizedString(), for: .normal)
        lblFromKey.text = model.senderUserId
        lblToKey.text = model.destUserId
        lblName.text = signer.title
        lblSignnature.text = signer.publicKey
        lblMoney.text = model.amount
        lblNote.text = model.note
        viewTransaction.layer.cornerRadius = 5
        viewTransaction.layer.borderWidth = 0.5
        viewTransaction.layer.borderColor = UIColor.lightGray.cgColor
        keyPairToSign = MnemonicHelper.getKeyPairFrom(signer.mnemonic!)
        do {
            let envelope = try TransactionEnvelopeXDR(xdr:model.transactionXDR)
            let transactionHash =  try [UInt8](envelope.tx.hash(network: .testnet))
            let decoratedSignature = keyPairToSign.signDecorated(transactionHash)
            let signatures = decoratedSignature.signature
            self.signature = signatures.base64EncodedString(options: NSData.Base64EncodingOptions())
        } catch {
            print("Invalid xdr string")
        }

    }

    @IBAction func tappedConfirmTransactions(_ sender: Any) {
        let application = UIApplication.shared
        let luvaApp = "luvaapp://?signature=\(self.signature!)&logId=\(self.model.logId)&signerPublicKey=\(self.signer.publicKey!)"
        let appUrl = URL(string: luvaApp)!
        if application.canOpenURL(appUrl) {
            application.open(appUrl, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func tappedCancelTransactions(_ sender: Any) {
        
    }
}
