//
//  TransactionsViewController.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 10/7/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class TransactionsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

}
