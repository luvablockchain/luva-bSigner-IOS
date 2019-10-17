//
//  UICustomView.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 10/15/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit

class UICustomView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    open func setupView() {
        let view = viewFromNibForClass()
        addFullSubView(child: view)
    }

}
