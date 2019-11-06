//
//  TransactionTableViewCell.swift
//  bSigner
//
//  Created by Nguyen Xuan Khang on 11/5/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {

    @IBOutlet weak var lblTransactionXDR: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
