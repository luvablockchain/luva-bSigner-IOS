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
    
    @IBOutlet weak var viewSignnature: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnCopy: UIButton!
    @IBOutlet weak var lblPublicKey: UILabel!
    @IBOutlet weak var imgQRCode: UIImageView!
    
    var model:SignnatureModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnHelp?.isHidden = true
        btnHelp?.setImage(UIImage(named: "ic_settings")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        btnHelp?.tintColor = BaseViewController.MainColor
        btnCopy.setImage(UIImage(named: "ic_copy")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        btnCopy.tintColor = BaseViewController.MainColor
        btnCopy.setTitle(" " + "Copy Key", for: .normal)
        btnCopy.layer.cornerRadius = 5
        btnCopy.layer.borderWidth = 1
        btnCopy.layer.borderColor = BaseViewController.MainColor.cgColor
        UserDefaultsHelper.accountStatus = .waitingToBecomeSinger
        lblName.text = model.title
        viewSignnature.layer.cornerRadius = 5
        viewSignnature.layer.borderWidth = 0.5
        viewSignnature.layer.borderColor = UIColor.lightGray.cgColor
        self.lblPublicKey.text = model.publicKey
        self.imgQRCode.image = generateQRCode(from: model.publicKey!)
    }
            
    @IBAction func tappedCopyPublicKey(_ sender: Any) {
        UIPasteboard.general.string = model.publicKey
        HUD.flash(.success, delay: 1.0)
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
