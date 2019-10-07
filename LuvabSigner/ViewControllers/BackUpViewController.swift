//
//  BackUpViewController.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 9/17/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit

class BackUpViewController: BaseViewController {

    @IBOutlet weak var imgKey: UIImageView!
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var lblNote: UILabel!
    @IBOutlet weak var lblBackUp: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        lblBackUp.text = "Backup Your Account".localizedString()
        lblNote.text = "You will be shown a 12 word recovery phrase".localizedString() + ". " + "It will allow you to recover access to your account in case your phone is lost or stolen".localizedString() + "."
        btnConfirm.layer.cornerRadius = 5
        btnConfirm.setTitle("I Understand".localizedString(), for: .normal)
        navigationController?.setNavigationBarHidden(false, animated: false)
        imgKey.image = UIImage.init(named: "ic_key")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        imgKey.tintColor = BaseViewController.MainColor
    }

    @IBAction func tappedConfirmCreateAccount(_ sender: Any) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "mnemonicGenerationViewController") as? MnemonicGenerationViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
}
