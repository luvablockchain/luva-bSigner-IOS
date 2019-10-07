//
//  SignatureTableViewCell.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 10/7/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit

class SignatureTableViewCell: UITableViewCell {

    static let key = "SignatureTableViewCell"
    
    static let nib = UINib(nibName: "SignatureTableViewCell", bundle: nil)
    
    @IBOutlet weak var btnDelete: UIButton!
    
    @IBOutlet weak var btnEdit: UIButton!
    
    @IBOutlet weak var lblPublicKey: UILabel!
    
    @IBOutlet weak var txtTitle: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 1
        layer.masksToBounds = true
        self.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        btnEdit.setImage(UIImage(named: "ic_edit")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        btnEdit.tintColor = BaseViewController.MainColor
        btnDelete.setImage(UIImage(named: "ic_delete")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        btnDelete.tintColor = BaseViewController.MainColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func tappedDeleteSignature(_ sender: Any) {
        
    }
    
    @IBAction func tappedEditSignatureTitle(_ sender: Any) {
        txtTitle.becomeFirstResponder()
    }
    
    override open var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            var frame =  newFrame
            frame.origin.y += 10
            frame.origin.x += 10
            frame.size.height -= 10
            frame.size.width -= 2 * 10
            super.frame = frame
        }
    }
}
