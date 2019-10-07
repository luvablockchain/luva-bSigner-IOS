//
//  MainViewController.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 9/27/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import stellarsdk
import PKHUD

class MainViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var listKey:[String] = []
    var index = 0
    var btnAdd:UIButton?
    
    override func viewDidLoad() {
        if let _ = navigationController {
            btnAdd = UIButton.init(type: .system)
            if #available(iOS 11.0, *) {
                btnAdd?.contentHorizontalAlignment = .trailing
            }
            btnAdd!.setImage(UIImage(named: "ic_plus")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
            btnAdd!.tintColor = BaseViewController.MainColor
            btnAdd!.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            btnAdd!.addTarget(self, action:#selector(tappedAtRightButton), for: .touchUpInside)
            let rightBarButton = UIBarButtonItem()
            rightBarButton.customView = btnAdd
            
            self.navigationItem.rightBarButtonItem = rightBarButton
        }
        if let publicKey =  KeychainWrapper.standard.string(forKey: "PUBLICKEY") {
            listKey.append(publicKey)
        }
        tableView.separatorStyle = .none
        UserDefaultsHelper.accountStatus = .waitingToBecomeSinger
    }
    
    @objc func tappedAtRightButton(sender:UIButton) {
        if let mnemonic = KeychainWrapper.standard.string(forKey: "MNEMONIC") {
            HUD.show(.labeledProgress(title: nil, subtitle: "Loading..."))
            DispatchQueue.global(qos: .background).async {
                self.index = self.index + 1
                let publickey = MnemonicHelper.getKeyPairFrom(mnemonic, index: self.index).accountId
                DispatchQueue.main.async {
                    if publickey != ""
                    {
                        self.listKey.append(publickey)
                        self.tableView.reloadData()
                        HUD.hide()
                    }
                }
            }
        }
    }
    
    @objc func tappedEditTitleSignature(sender:UIButton) {
        print("aaa")
    }


}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listKey.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "mainTableViewCell") as! MainTableViewCell
        cell.imgKey.image = UIImage.init(named: "ic_key")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        cell.imgKey.tintColor = BaseViewController.MainColor
        cell.lblKey.text = listKey[indexPath.row]
        cell.txtTitle.text = "Signature " + "\(indexPath.row)"
        cell.btnEdit.addTarget(self, action:#selector(tappedEditTitleSignature), for: .touchUpInside)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let application = UIApplication.shared
//        let luvaApp = "luvaapp://"
//        let appUrl = URL(string: luvaApp)!
//        if application.canOpenURL(appUrl) {
//            application.open(appUrl, options: [:], completionHandler: nil)
//        }
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "publicKeyViewController") as? PublicKeyViewController
        vc?.publicKey = listKey[indexPath.row]
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.pushViewController(vc!, animated: true)

    }
}
