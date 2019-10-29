//
//  SignUpViewController.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 9/17/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit
import PKHUD

class SignUpViewController: UIViewController {
        
    @IBOutlet weak var lblPolicy: UILabel!
    @IBOutlet weak var lblHelp: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnRecoverAccount: UIButton!
    @IBOutlet weak var btnCreateAccount: UIButton!
    
    var isNewSignature = false

    override func viewDidLoad() {
        super.viewDidLoad()
        ConfigModel.sharedInstance.loadLocalized()
        lblTitle.text = "Multiply your security".localizedString()
        lblHelp.text = "First time user".localizedString() + "? " + "See our Help section".localizedString()
        lblPolicy.text = "BY REGISTER YOU AGREE TO OUR TERMS OF SERVICE AND PRIVACY POLICY".localizedString()
        btnCreateAccount.setTitle("CREATE ACCOUNT".localizedString(), for: .normal)
        btnCreateAccount.layer.cornerRadius = 5
        btnRecoverAccount.setTitle("RESTORE ACCOUNT".localizedString(), for: .normal)
        btnRecoverAccount.layer.cornerRadius = 5
        btnRecoverAccount.layer.borderWidth = 0.5
        btnRecoverAccount.layer.borderColor = BaseViewController.MainColor.cgColor
    }
        
    @IBAction func tappedCreateAccount(_ sender: Any) {
        pushBackUpViewController(isNewSignature: isNewSignature)
    }
    
    @IBAction func tappedRecoverAccount(_ sender: Any) {
        pushRestoreAccountViewController(isNewSignature: isNewSignature)
    }
}

