//
//  TransactionTableViewCell.swift
//  bSigner
//
//  Created by Nguyen Xuan Khang on 11/5/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {

    @IBOutlet weak var viewTransaction: UIView!
    @IBOutlet weak var lblStatus: UILabel!
    
    @IBOutlet weak var lblDateTime: UILabel!
    @IBOutlet weak var lblName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        viewTransaction.layer.cornerRadius = 5
        viewTransaction.layer.borderWidth = 1
        viewTransaction.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
