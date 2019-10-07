//
//  PublicKeyViewController.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 9/23/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import PKHUD

class PublicKeyViewController: BaseViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnCopy: UIButton!
    @IBOutlet weak var lblPublicKey: UILabel!
    @IBOutlet weak var imgQRCode: UIImageView!
    
    var publicKey = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        btnHelp?.setImage(UIImage(named: "ic_settings")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        btnHelp?.tintColor = BaseViewController.MainColor
        lblTitle.text = "Your bSigner Public Key".localizedString()
        lblDescription.text = "This key will be set as a signer for your Stellar account".localizedString() + ". " + "To protect your LuvaPay account, copy and paste the key to LuvaPay".localizedString() + "."
        btnCopy.setImage(UIImage(named: "ic_copy")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        btnCopy.tintColor = BaseViewController.MainColor
        btnCopy.setTitle(" " + "Copy Key", for: .normal)
        btnCopy.layer.cornerRadius = 5
        btnCopy.layer.borderWidth = 1
        btnCopy.layer.borderColor = BaseViewController.MainColor.cgColor
        btnNext.setTitle("NEXT".localizedString(), for: .normal)
        btnNext.layer.cornerRadius = 5
        UserDefaultsHelper.accountStatus = .waitingToBecomeSinger
        self.lblPublicKey.text = publicKey
        self.imgQRCode.image = generateQRCode(from: publicKey)
    }
    
    override func tappedAtRightButton(sender: UIButton) {
        ApplicationCoordinatorHelper.logout()
    }
        
    @IBAction func tappedCopyPublicKey(_ sender: Any) {
        UIPasteboard.general.string = publicKey
        HUD.flash(.success, delay: 1.0)
    }
    
    @IBAction func tappedNextButton(_ sender: Any) {
        
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }

}
