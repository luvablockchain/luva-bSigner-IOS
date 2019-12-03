//
//  DetailTransactionTableViewCell.swift
//  bSigner
//
//  Created by Nguyen Xuan Khang on 11/8/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit

protocol DetailTransactionTableViewCellDelegate:NSObject {
    func didSignTransaction(index:Int)
}

class DetailTransactionTableViewCell: UITableViewCell {

    @IBOutlet weak var btnSignTransaction: UIButton!
    @IBOutlet weak var viewDetails: UIView!
    
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var lblStatus: UILabel!
    
    @IBOutlet weak var lblSignature: UILabel!
    
    @IBOutlet weak var imgStatus: UIImageView!
    
    @IBOutlet weak var lblWeight: UILabel!
    weak var delegate: DetailTransactionTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewDetails.layer.cornerRadius = 5
        viewDetails.layer.borderWidth = 1
        viewDetails.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        selectionStyle = .none
        btnSignTransaction.setTitle("Approve".localizedString(), for: .normal)
        btnSignTransaction.layer.cornerRadius = 20
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    @IBAction func tappedSignTransaction(_ sender: Any) {
        delegate?.didSignTransaction(index: btnSignTransaction.tag)
    }
}
