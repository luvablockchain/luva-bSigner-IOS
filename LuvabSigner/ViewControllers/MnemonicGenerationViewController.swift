//
//  MnemonicGenerationViewController.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 9/17/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit
import stellarsdk
import PKHUD
import EZAlertController
import SwiftKeychainWrapper

class MnemonicGenerationViewController: BaseViewController {

    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var lblConfirm: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblTitleCopy: UILabel!
    @IBOutlet weak var btnCopy: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    
    var mnemonicList: [String] = []
    var mnemonic: String = ""
    var isAddAcount = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Recovery Phrase".localizedString()
        btnNext.layer.cornerRadius = 5
        btnNext.setTitle("NEXT".localizedString(), for: .normal)
        btnCopy.setImage(UIImage(named: "ic_copy")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        btnCopy.tintColor = BaseViewController.MainColor
        btnCopy.setTitle(" " + "Copy".localizedString(), for: .normal)
        btnCopy.layer.cornerRadius = 5
        btnCopy.layer.borderWidth = 1
        btnCopy.layer.borderColor = BaseViewController.MainColor.cgColor
        lblTitle.text = "Recovery phrase can help you to recover access to your account in case your phone is lost or stolen".localizedString() + "."
        lblTitleCopy.text = "Write down these 12 words and keep them secure".localizedString() + ". " + "Don't email them or screenshot them".localizedString() + "."
        lblConfirm.text = "YOU WILL NEED TO CONFIRM RECOVERY PHRASE ON THE NEXT SCREEN".localizedString()
        collectionView.register(MnemonicCollectionViewCell.nib, forCellWithReuseIdentifier: MnemonicCollectionViewCell.key)
        
        let mnemonicData = MnemonicHelper.getWordMnemonic()
        mnemonicList = mnemonicData.separatedWords
        mnemonic = mnemonicData.mnemonic

    }
    
    override func viewDidLayoutSubviews() {
        AppearanceHelper.setDashBorders(for: collectionView, with: BaseViewController.MainColor.cgColor)
    }
    
    override func tappedAtLeftButton(sender: UIButton) {
        EZAlertController.alert("Are you sure".localizedString() + "?", message:"This action will cancel account creation".localizedString() + ". " + "Shown recovery phrase will be deleted".localizedString(), buttons: ["Cancel".localizedString(), "OK".localizedString()]) { (alertAction, position) -> Void in
            if position == 0 {
                self.dismiss(animated: true, completion: nil)
            } else if position == 1 {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }

    @IBAction func tappedCopyToClipBoard(_ sender: Any) {
        let mnemonic = MnemonicHelper.getStringFromSeparatedWords(in: mnemonicList)
        UIPasteboard.general.string = mnemonic
        HUD.flash(.success, delay: 1.0)
    }
    
    @IBAction func tappedNextButton(_ sender: Any) {
        pushMnemonicVerificationViewController(mnemoricList: self.mnemonicList,isAddAccount: isAddAcount)
    }
}

extension MnemonicGenerationViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return mnemonicList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:MnemonicCollectionViewCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: MnemonicCollectionViewCell.key, for: indexPath) as! MnemonicCollectionViewCell
        cell.lblTitle.text = mnemonicList[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let width = (collectionView.frame.width - 40)/3
        return CGSize(width: width, height: 30)
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
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }

}
