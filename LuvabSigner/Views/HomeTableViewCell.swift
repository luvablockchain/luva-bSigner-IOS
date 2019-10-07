//
//  HomeTableViewCell.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 10/7/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {

    @IBOutlet weak var lblPublicKey: UILabel!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 1
        layer.masksToBounds = true
        self.layer.borderColor = UIColor.groupTableViewBackground.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
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
