//
//  MnemonicVerificationViewController.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 9/17/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import PKHUD

class MnemonicVerificationViewController: BaseViewController {

    @IBOutlet weak var btnClear: UIButton!
    @IBOutlet weak var lblError: UILabel!
    @IBOutlet weak var collectionView2: UICollectionView!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var collectionView1: UICollectionView!
    @IBOutlet weak var viewBoderCollection: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    var mnemoricList: [String] = []
    
    var shuffledMnemonicList: [String] = []
    
    var mnemonicListForVerification: [String] = []
    
    private var passcode: String = ""
    
    var isAddAcount = false
    
    var model:[SignnatureModel] = []
    
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Verify Recovery Phrase".localizedString()
        lblError.isHidden = true
        lblTitle.text = "Tap the words in the correct order".localizedString() + "."
        btnClear.isHidden = true
        btnClear.setImage(UIImage(named: "ic_delete")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        btnClear.tintColor = BaseViewController.MainColor
        btnClear.setTitle(" " + "Clear".localizedString(), for: .normal)
        btnNext.setTitle("NEXT".localizedString(), for: .normal)
        btnNext.layer.cornerRadius = 5
        btnNext.isEnabled = false
        collectionView1.register(MnemonicCollectionViewCell.nib, forCellWithReuseIdentifier: MnemonicCollectionViewCell.key)
        collectionView2.register(MnemonicCollectionViewCell.nib, forCellWithReuseIdentifier: MnemonicCollectionViewCell.key)
        shuffledMnemonicList = mnemoricList.shuffled()
        collectionView2.allowsMultipleSelection = true
        if let loadedData = UserDefaults().data(forKey: "SIGNNATURE") {

            if let signnatureModel = NSKeyedUnarchiver.unarchiveObject(with: loadedData) as? [SignnatureModel] {
                self.model = signnatureModel
                if let index = KeychainWrapper.standard.integer(forKey: "INDEX") {
                    self.index = index
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        AppearanceHelper.setDashBorders(for: viewBoderCollection, with: BaseViewController.MainColor.cgColor)
    }
        
    @IBAction func tappedClearButton(_ sender: Any) {
        deselectShuffledCollectionView()
        mnemonicListForVerification.removeAll()
        collectionView1.reloadData()
        validateVerificationList()
        btnClear.isHidden = true
    }
    
    @IBAction func tappedNextButton(_ sender: Any) {
        if isAddAcount {
            
            HUD.show(.labeledProgress(title: nil, subtitle: "Loading..."))
            
            DispatchQueue.global(qos: .background).async {
                let mnemonic = MnemonicHelper.getStringFromSeparatedWords(in: self.mnemoricList)
                let publickey = MnemonicHelper.getKeyPairFrom(mnemonic).accountId
                self.index += 1
                self.model.append(SignnatureModel.init(title: "Signature".localizedString() + " " + "\(self.index)", publicKey: publickey,mnemonic:mnemonic))
                let data = NSKeyedArchiver.archivedData(withRootObject: self.model)
                UserDefaults().set(data, forKey: "SIGNNATURE")
                KeychainWrapper.standard.set(self.index, forKey: "INDEX")
                DispatchQueue.main.async {
                    if publickey != ""
                    {
                        HUD.hide()
                        self.pushMainTabbarViewController()
                    }
                }
            }
        } else {
            pushToLockScreenViewController(delegate: self, isCreateAccount: true)
        }
    }
    
    func validateVerificationList() {
        if mnemonicListForVerification.count > 0 {
            btnClear.isHidden = false
        } else {
            btnClear.isHidden = true
        }
        guard mnemonicListForVerification.count == 12 else {
            btnNext.isEnabled = false
            btnNext.backgroundColor = UIColor.init(rgb: 0xcacaca)
            lblError.isHidden = true
            AppearanceHelper.setDashBorders(for: viewBoderCollection, with: BaseViewController.MainColor.cgColor)
            return
        }
        
        if mnemonicListForVerification == mnemoricList {
            btnNext.isEnabled = true
            btnNext.backgroundColor = BaseViewController.MainColor
        } else {
            btnNext.isEnabled = false
            btnNext.backgroundColor = UIColor.init(rgb: 0xcacaca)
            lblError.isHidden = false
            lblError.text = "Wrong order".localizedString() + ". " + "Please try again".localizedString() + "."
            AppearanceHelper.setDashBorders(for: viewBoderCollection, with: UIColor.red.cgColor)
        }
    }
    
    func deselectShuffledCollectionView() {
        for index in 0...shuffledMnemonicList.count {
            collectionView2.deselectItem(at: IndexPath(item: index, section: 0), animated: true)
        }
    }
    
    func getIndexPathFromShuffledMnemonicList(by index: Int) -> IndexPath {
        let indexInShuffledList =
            shuffledMnemonicList.firstIndex(of: mnemonicListForVerification[index])
        return IndexPath(item: indexInShuffledList!, section: 0)
    }
}
extension MnemonicVerificationViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionView1 {
            return mnemonicListForVerification.count

        } else {
            return shuffledMnemonicList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if collectionView == collectionView1 {
            let cell:MnemonicCollectionViewCell = self.collectionView1.dequeueReusableCell(withReuseIdentifier: MnemonicCollectionViewCell.key, for: indexPath) as! MnemonicCollectionViewCell
            cell.lblTitle.text = mnemonicListForVerification[indexPath.row]
            cell.lblTitle.textColor = UIColor.black
            cell.backgroundColor = UIColor.white
            return cell
        } else {
            let cell:MnemonicCollectionViewCell = self.collectionView2.dequeueReusableCell(withReuseIdentifier: MnemonicCollectionViewCell.key, for: indexPath) as! MnemonicCollectionViewCell
            cell.backgroundColor = BaseViewController.MainColor
            cell.layer.cornerRadius = 5
            cell.lblTitle.textColor = UIColor.white
            cell.lblTitle.text = shuffledMnemonicList[indexPath.row]
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == collectionView1 {
            let newIndexPath = getIndexPathFromShuffledMnemonicList(by: indexPath.item)
            collectionView2.deselectItem(at: newIndexPath, animated: false)
            mnemonicListForVerification.remove(at: indexPath.item)
            collectionView1.reloadData()
            validateVerificationList()

        } else {
            mnemonicListForVerification.append(shuffledMnemonicList[indexPath.item])
            collectionView1.reloadData()
            validateVerificationList()
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if collectionView == collectionView1 {
            let width = (collectionView1.frame.width - 40)/3
            return CGSize(width: width, height: 30)

        } else {
            return CGSize(width: 80, height: 30)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12.0
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}
extension MnemonicVerificationViewController: LockScreenViewControllerDelegate {
    func didConfirmPassCode() {
        
    }
    
    func didChangePassCode() {
    
    }
    
    func didPopViewController() {
        
    }
    
    func didConfirmPassCodeSuccess() {
        
    }
    
    func didDisablePassCodeSuccess() {
        
    }
    
    func didInPutPassCodeSuccess(_ pass: String) {
        if passcode.isEmpty {
            passcode = pass
            let mnemonic = MnemonicHelper.getStringFromSeparatedWords(in: mnemoricList)
            pushToLockScreenViewController(delegate: self, passCode: pass,mnemonic: mnemonic,isCreateAccount: true)
        }
    }
}
