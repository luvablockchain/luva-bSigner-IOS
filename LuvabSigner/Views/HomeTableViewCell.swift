//
//  HomeTableViewCell.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 10/7/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit

protocol HomeTableViewCellDelegate:NSObject {
    func didEditTitleSignature(index:Int)
    func didDeleteSignature(index:Int)
}

class HomeTableViewCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var txtTitle: UITextField!
    
    @IBOutlet weak var btnDelete: UIButton!
    
    @IBOutlet weak var btnEdit: UIButton!
    
    @IBOutlet weak var lblPublicKey: UILabel!
    
    @IBOutlet weak var viewSignature: UIView!
        
    @IBOutlet weak var viewEdit: UIView!
    weak var delegate:HomeTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewSignature.layer.cornerRadius = 5
        viewSignature.layer.borderWidth = 1
        
        btnEdit.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        btnEdit.setImage(UIImage(named: "ic_edit")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        btnEdit.tintColor = BaseViewController.MainColor
        
        btnDelete.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        btnDelete.setImage(UIImage(named: "ic_trash")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        btnDelete.tintColor = .red
        btnDelete.isHidden = true
        btnEdit.isHidden = true
        txtTitle.isEnabled = false
        txtTitle.isHidden = true
        selectionStyle = .none
        
        if #available(iOS 12.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                txtTitle.textColor = .white
                lblTitle.textColor = .white
                lblPublicKey.textColor = .white
                viewSignature.layer.borderColor = UIColor.white.cgColor
            } else {
                txtTitle.textColor = .darkText
                lblTitle.textColor = .darkText
                lblPublicKey.textColor = .darkText
                viewSignature.layer.borderColor = UIColor.groupTableViewBackground.cgColor
            }
        }

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func tappedDeleteSignature(_ sender: Any) {
        delegate?.didDeleteSignature(index: btnDelete.tag)
    }
    
    @IBAction func tappedEditSignatureTitle(_ sender: Any) {
        txtTitle.isEnabled = true
        txtTitle.becomeFirstResponder()
        txtTitle.isHidden = false
        lblTitle.isHidden = true
        delegate?.didEditTitleSignature(index: btnEdit.tag)
    }
}
