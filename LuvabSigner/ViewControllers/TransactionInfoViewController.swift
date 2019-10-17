//
//  TransactionInfoViewController.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 10/17/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit

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
        lblFromKey.text = "GDPKQOKONZJ4LOGS2LGEHWVNVEHQN2JE4Z4CV7QSSNI6ZBNPJY62IK53"
        lblToKey.text = "GCASWWNIP4F4XEWIGWSB7EKGIYDGDVIYDUGNLRLWNHHUW2EBROSV5YTI"
        lblName.text = "Test"
        lblSignnature.text = "GDPKQOKONZJ4LOGS2LGEHWVNVEHQN2JE4Z4CV7QSSNI6ZBNPJY62IK53"
        lblMoney.text = "200.000"
        lblNote.text = "test"
        viewTransaction.layer.cornerRadius = 5
        viewTransaction.layer.borderWidth = 0.5
        viewTransaction.layer.borderColor = UIColor.lightGray.cgColor
    }

    @IBAction func tappedConfirmTransactions(_ sender: Any) {
        
    }
    
    @IBAction func tappedCancelTransactions(_ sender: Any) {
        
    }
}
