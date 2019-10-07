//
//  SignatureViewController.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 10/2/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import PKHUD

struct SignatureModel {
    var keys:[KeyModel]!
    var title:String
}
struct KeyModel {
    var key:String
}

class SignatureViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var btnEnableEdit: UIButton!
    
    var sections: [SignatureModel] = []
    var index:Int = 0
    var btnAdd:UIButton?
    var shouldShowLockScreen = true
    var timeBackGround:Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ConfigModel.sharedInstance.loadLocalized()
        if let _ = navigationController {
            btnAdd = UIButton.init(type: .system)
            if #available(iOS 11.0, *) {
                btnAdd?.contentHorizontalAlignment = .trailing
            }
            btnAdd!.setImage(UIImage(named: "ic_settings")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
            btnAdd!.tintColor = BaseViewController.MainColor
            btnAdd!.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            btnAdd!.addTarget(self, action:#selector(tappedAtRightButton), for: .touchUpInside)
            let rightBarButton = UIBarButtonItem()
            rightBarButton.customView = btnAdd

            self.navigationItem.rightBarButtonItem = rightBarButton
        }

        if let publicKey =  KeychainWrapper.standard.string(forKey: "PUBLICKEY") {
            sections = [SignatureModel(keys:[KeyModel(key: publicKey)], title: "Signature".localizedString() + " " + "\(self.index)")]
            collectionView.reloadData()
        }
        ConfigModel.sharedInstance.enablePassCode = .off
        ConfigModel.saveToDB()

        if ConfigModel.sharedInstance.enablePassCode == .on {
            presentToLockScreenViewController(delegate: self)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification
            , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification
            , object: nil)
        UserDefaultsHelper.accountStatus = .waitingToBecomeSinger
    }
    
    
    @objc func willEnterForeground() {
        let currentDate = Date()
        if let time = timeBackGround {
            let timeInterval  =  currentDate.timeIntervalSince1970 - time.timeIntervalSince1970
            if Int(timeInterval) < ConfigModel.sharedInstance.configType.second {
                shouldShowLockScreen = false
            }
        }
    }
    
    @objc func didEnterBackground() {
        if ConfigModel.sharedInstance.enablePassCode == .on {
            self.timeBackGround = Date()
            let second = ConfigModel.sharedInstance.configType.second
            shouldShowLockScreen = true
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(second)) {
                if self.shouldShowLockScreen {
                    self.presentLockScreen()
                }
            }
        }
    }
    
    func presentLockScreen() {
        if let topViewController = UIApplication.topViewController() {
            topViewController.presentToLockScreenViewController(delegate: self)
        }
    }


    
    @objc func tappedAtRightButton(sender:UIButton) {
//        if let mnemonic = KeychainWrapper.standard.string(forKey: "MNEMONIC") {
//            HUD.show(.labeledProgress(title: nil, subtitle: "Loading..."))
//            DispatchQueue.global(qos: .background).async {
//                self.index = self.index + 1
//                let publickey = MnemonicHelper.getKeyPairFrom(mnemonic, index: self.index).accountId
//                DispatchQueue.main.async {
//                    if publickey != ""
//                    {
//                        self.sections.append(SignatureModel(keys:[KeyModel(key: publickey)], title: "Signature " + "\(self.index)"))
//                        self.collectionView.reloadData()
//                        HUD.hide()
//                    }
//                }
//            }
//        }
        let vc = SettingsViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func tappedEnableEditButton(_ sender: Any) {
        btnEnableEdit.isSelected = !btnEnableEdit.isSelected
        if btnEnableEdit.isSelected {
            btnEnableEdit.setImage(UIImage(named: "ic_success-1"), for: .normal)
        } else {
            btnEnableEdit.setImage(UIImage(named: "ic_enableEdit"), for: .normal)
        }
    }
    
}

extension SignatureViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let item = sections[section]
        
        return item.keys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = sections[indexPath.section]
        let cell:SignatureCollectionViewCell = self.collectionView.dequeueReusableCell(withReuseIdentifier:"signatureCollectionViewCell", for: indexPath) as! SignatureCollectionViewCell
        cell.imgKey.image = UIImage.init(named: "ic_key")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        cell.imgKey.tintColor = BaseViewController.MainColor
        cell.lblKey.text = section.keys[indexPath.row].key
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = sections[indexPath.section]
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "publicKeyViewController") as? PublicKeyViewController
        vc?.publicKey = section.keys[indexPath.row].key
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard
                let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: "headerSignatureCollectionReusableView",
                    for: indexPath) as? HeaderSignatureCollectionReusableView
                else {
                    fatalError("Invalid view type")
            }
            let section = sections[indexPath.section]
            headerView.txtTitle.text = section.title
            headerView.txtTitle.isUserInteractionEnabled = false
            headerView.btnEdit.setImage(UIImage(named: "ic_edit")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
            headerView.btnEdit.tintColor = BaseViewController.MainColor
            
            return headerView
            
        default:
            assert(false, "Invalid element type")
            return UICollectionReusableView(frame: CGRect.zero)
            
        }
    }
}

extension SignatureViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.collectionView.bounds.width, height: sections[section].title.heightWithConstrainedWidth(width: collectionView.bounds.width - 70, font: UIFont.systemFont(ofSize: 17)) + 20)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let width  = (view.frame.width - 20)
        return CGSize(width: width, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
}

extension SignatureViewController: HeaderSignatureCollectionReusableViewDelegate {
    func didChangeTitleSuccess(title: String) {
        
    }
}

extension SignatureViewController: LockScreenViewControllerDelegate {
    func didChangePassCode() {
        
    }
    func didConfirmPassCodeSuccess() {
        dismiss(animated: true, completion: nil)
    }
    func didInPutPassCodeSuccess(_ pass: String) {
    }
    
    func didConfirmPassCode() {
        
    }
    func didPopViewController() {
    }
    
    func didDisablePassCodeSuccess() {
    }
}

