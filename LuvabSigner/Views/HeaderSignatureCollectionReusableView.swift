//
//  HeaderSignatureCollectionReusableView.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 10/2/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit

protocol HeaderSignatureCollectionReusableViewDelegate: AnyObject {
    func didChangeTitleSuccess(title:String)
}

class HeaderSignatureCollectionReusableView: UICollectionReusableView {
        
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var txtTitle: UITextView!
    
    weak var delegate:HeaderSignatureCollectionReusableViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        
    }
    @IBAction func tappedChangeTittle(_ sender: Any) {
        txtTitle.isUserInteractionEnabled = true
        txtTitle.becomeFirstResponder()
        delegate?.didChangeTitleSuccess(title: txtTitle.text!)
    }
}
