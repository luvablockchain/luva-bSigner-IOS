//
//  CustomSignersView.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 10/15/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit

class CustomSignersView: UICustomView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        
    }
    
    class func initCustomSignersView(parent: UIView, tableView:UITableView, button:UIButton) {
        let signersView = CustomSignersView.init(frame: .zero)
        signersView.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(signersView)
        NSLayoutConstraint.activate([
            button.bottomAnchor.constraint(equalTo: signersView.topAnchor,constant: -10),
            parent.leadingAnchor.constraint(equalTo: signersView.leadingAnchor),
            parent.trailingAnchor.constraint(equalTo: signersView.trailingAnchor)
            ])
    }
    class func removeCustomSignersView(parent: UIView) {
        for view: UIView in parent.subviews {
            if view is CustomSignersView {
                view.removeFromSuperview()
                break
            }
        }
    }

}
