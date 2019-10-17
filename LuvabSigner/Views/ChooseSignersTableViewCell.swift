//
//  ChooseSignersTableViewCell.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 10/14/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit

class ChooseSignersTableViewCell: UITableViewCell {
    @IBOutlet weak var viewSignnature: UIView!
    
    @IBOutlet weak var imgKey: UIImageView!
    
    @IBOutlet weak var lblKey: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        viewSignnature.layer.cornerRadius = 5
        viewSignnature.layer.borderWidth = 1
        viewSignnature.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        selectionStyle = .none
        imgKey.image = UIImage.init(named: "ic_key")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        imgKey.tintColor = UIColor.lightGray
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            viewSignnature.backgroundColor = BaseViewController.MainColor
            imgKey.image = UIImage.init(named: "ic_success-2")
            lblKey.textColor = .white
        } else {
            viewSignnature.backgroundColor = .white
            imgKey.image = UIImage.init(named: "ic_key")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            imgKey.tintColor = UIColor.lightGray
            lblKey.textColor = .darkText
        }
    }

}
