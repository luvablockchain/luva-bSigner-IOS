//
//  MainTableViewCell.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 9/27/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell {

    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var lblKey: UILabel!
    @IBOutlet weak var imgKey: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 1
        layer.masksToBounds = true
        self.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        txtTitle.isUserInteractionEnabled = false
        btnEdit.setImage(UIImage(named: "ic_edit")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        btnEdit.tintColor = BaseViewController.MainColor

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
