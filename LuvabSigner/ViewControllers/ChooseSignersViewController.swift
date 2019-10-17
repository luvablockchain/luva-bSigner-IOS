//
//  ChooseSignersViewController.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 10/14/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class ChooseSignersViewController: UIViewController {

    @IBOutlet weak var btnChoose: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var listSigners:[SignnatureModel] = []
    var signnature:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTitle.text = "Your Signers"
        btnChoose.isEnabled = false
        btnChoose.setTitle("Choose", for: .normal)
        btnChoose.layer.cornerRadius = 20
        tableView.separatorStyle = .none
        if let loadedData = UserDefaults().data(forKey: "SIGNNATURE") {
               if let signnatureModel = NSKeyedUnarchiver.unarchiveObject(with: loadedData) as? [SignnatureModel] {
                   self.listSigners = signnatureModel
               }
           }

    }
        
    @IBAction func tappedChooseSigner(_ sender: Any) {
        let application = UIApplication.shared
        let luvaApp = "luvaapp://?signers=" + signnature
        let appUrl = URL(string: luvaApp)!
        if application.canOpenURL(appUrl) {
            application.open(appUrl, options: [:], completionHandler: nil)
        }
    }
}
    
extension ChooseSignersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listSigners.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "chooseSignersTableViewCell") as! ChooseSignersTableViewCell
        cell.lblKey.text = listSigners[indexPath.row].publicKey
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        btnChoose.isEnabled = true
        btnChoose.backgroundColor = BaseViewController.MainColor
        btnChoose.setTitleColor(.white, for: .normal)
        signnature = listSigners[indexPath.row].publicKey!
    }
    
}
