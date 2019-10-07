//
//  SignatureCollectionViewCell.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 10/2/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit


class SignatureCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var lblKey: UILabel!
    @IBOutlet weak var imgKey: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 1
        layer.masksToBounds = true
        self.layer.borderColor = UIColor.groupTableViewBackground.cgColor
    }
}
