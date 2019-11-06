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

    @IBOutlet weak var tableView: UITableView!
    
    var listTransaction:[TransactionModel] = []
     
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Transaction List".localizedString()
        Broadcaster.register(bSignersNotificationOpenedDelegate.self, observer: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

}

extension TransactionsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listTransaction.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "transactionTableViewCell", for: indexPath) as! TransactionTableViewCell
        return cell
    }
}

extension TransactionsViewController: bSignersNotificationOpenedDelegate {
    func notifyApproveTransaction(model: TransactionModel) {
        pushChooseSignersViewController(model: model)
    }
    
    func notifyChooseSigners() {
        self.pushChooseSignersViewController()
    }
}
