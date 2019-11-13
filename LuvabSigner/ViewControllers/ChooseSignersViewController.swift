//
//  ChooseSignersViewController.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 10/14/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import EZAlertController

class ChooseSignersViewController: UIViewController {

    @IBOutlet weak var btnChoose: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var listSigners:[SignatureModel] = []
    
    var signnature:String = ""
    
    var model:TransactionModel!
    
    var signers:SignatureModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTitle.text = "Your Signers".localizedString()
        btnChoose.isEnabled = false
        btnChoose.setTitle("Choose".localizedString(), for: .normal)
        btnChoose.layer.cornerRadius = 20
        tableView.separatorStyle = .none
        if let loadedData = KeychainWrapper.standard.data(forKey: "SIGNATURE") {
               if let signnatureModel = NSKeyedUnarchiver.unarchiveObject(with: loadedData) as? [SignatureModel] {
                   self.listSigners = signnatureModel
               }
        } else {
            EZAlertController.alert("", message:"Currently no signatures".localizedString() + ", " + "create new".localizedString(), buttons: ["Cancel".localizedString(), "OK".localizedString()]) { (alertAction, position) -> Void in
                if position == 0 {
                    self.dismiss(animated: true, completion: nil)
                } else if position == 1 {
                    self.pushSignUpViewController(isNewSignature: true)
                }
            }

        }
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification
            , object: nil)
        
    }
        
    @objc func didEnterBackground() {
        pushMainTabbarViewController()
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func tappedChooseSigner(_ sender: Any) {
        if model != nil {
            pushTransactionInfoViewController(signer: signers, model: model)
        } else {
            let application = UIApplication.shared
            let luvaApp = "luvaapp://?signers=" + signnature
            let appUrl = URL(string: luvaApp)!
            if application.canOpenURL(appUrl) {
                application.open(appUrl, options: [:], completionHandler: nil)
            }
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
        signers = listSigners[indexPath.row]
    }
}
