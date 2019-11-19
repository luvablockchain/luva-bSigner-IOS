//
//  RestoreAccountViewController.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 9/25/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import PKHUD
import EZAlertController

class RestoreAccountViewController: BaseViewController {
    
    @IBOutlet weak var viewMnemonic: UIView!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    
    var mnemonic: String = ""
    
    var suggestionList: [String] = []
    
    let possibleWordsNumberInMnemonic = (twelveWords: 12, twentyFourWords: 24)
    
    private var passcode: String = ""
    
    var isAddAcount = false
    
    var model:[SignatureModel] = []

    var mnemonicSuggestionsView: MnemonicSuggestionsView?
    
    var index = 0
    
    var checkMnemonic = false
        
    var txtMnemonic:UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Restore Signature".localizedString()
        mnemonicSuggestionsView = Bundle.main.loadNibNamed("MnemonicSuggestionsView",
                                                           owner: self,
                                                           options: nil)?.first as? MnemonicSuggestionsView
        mnemonicSuggestionsView?.delegate = self
        mnemonicSuggestionsView?.layer.shadowColor = UIColor.black.cgColor
        mnemonicSuggestionsView?.layer.shadowOffset = CGSize(width: 0, height: -1.0)
        mnemonicSuggestionsView?.layer.shadowOpacity = 0.2
        mnemonicSuggestionsView?.layer.shadowRadius = 4.0
        
        btnNext.setTitle("NEXT".localizedString(), for: .normal)
        btnNext.layer.cornerRadius = 5
        btnNext.isEnabled = false
        lblTitle.text = "Enter the 12 or 24 word recovery phrase you were given when you created your Luva bSigner account".localizedString() + "."
        txtMnemonic = UITextView.init(frame: .zero)
        txtMnemonic!.translatesAutoresizingMaskIntoConstraints = false
        viewMnemonic.addSubview(txtMnemonic!)
        txtMnemonic!.backgroundColor = UIColor.init(rgb: 0xDEE7D6)
        txtMnemonic!.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        txtMnemonic!.delegate = self
        txtMnemonic!.autocapitalizationType = .none
        NSLayoutConstraint.activate([
            txtMnemonic!.bottomAnchor.constraint(equalTo: viewMnemonic.bottomAnchor),
            txtMnemonic!.leadingAnchor.constraint(equalTo: viewMnemonic.leadingAnchor),
            txtMnemonic!.trailingAnchor.constraint(equalTo: viewMnemonic.trailingAnchor),
            txtMnemonic!.topAnchor.constraint(equalTo: viewMnemonic.topAnchor)
            ])
        txtMnemonic!.textContainerInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        txtMnemonic!.inputAccessoryView = mnemonicSuggestionsView
        if let loadedData = KeychainWrapper.standard.data(forKey: "SIGNATURE") {

            if let signnatureModel = NSKeyedUnarchiver.unarchiveObject(with: loadedData) as? [SignatureModel] {
                self.model = signnatureModel
                if let index = KeychainWrapper.standard.integer(forKey: "INDEX") {
                    self.index = index
                }
            }
        }
        ConfigModel.sharedInstance.accountType = .create
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        AppearanceHelper.setDashBorders(for: txtMnemonic!, with: BaseViewController.MainColor.cgColor)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }

    
    func add(_ suggestionWord: String, to text: String) {
        let updatedText = MnemonicHelper.addSuggestionWord(to: text, suggestionWord)
        clearSuggestionList()
        txtMnemonic!.text = updatedText
        mnemonic = updatedText
        validateMnemonic()
    }
    
    func clearSuggestionList() {
        suggestionList.removeAll()
        mnemonicSuggestionsView?.setData(suggestions: suggestionList)
    }
    
    func suggestionListRequest(by subString: String) {
        if let lastWord = MnemonicHelper.getSeparatedWords(from: String(subString)).last {
            suggestionList.append(contentsOf: MnemonicHelper.getAutocompleteSuggestions(userText: lastWord))
        }
        mnemonicSuggestionsView?.setData(suggestions: suggestionList)
    }
    
    func validateMnemonic() {
        let phrases = MnemonicHelper.getSeparatedWords(from: mnemonic)
        
        for word in phrases {
            if !MnemonicHelper.mnemonicWordIsExist(word) {
                btnNext.isEnabled = false
                btnNext.backgroundColor = UIColor.init(rgb: 0xcacaca)
                return
            }
        }
        
        guard phrases.count == possibleWordsNumberInMnemonic.twelveWords ||
            phrases.count == possibleWordsNumberInMnemonic.twentyFourWords else {
                btnNext.isEnabled = false
                btnNext.backgroundColor = UIColor.init(rgb: 0xcacaca)
                return
        }
        btnNext.isEnabled = true
        btnNext.backgroundColor = BaseViewController.MainColor
    }
    
    func textViewWasChanged(text: String) {
        clearSuggestionList()
        
        guard text.count > 0 else { return }
        
        mnemonic = text
        suggestionListRequest(by: text)
        validateMnemonic()
    }
    
    @IBAction func tappedRestoreAccount(_ sender: Any) {
        self.view.endEditing(true)
        for mnemonic in model {
            if mnemonic.mnemonic == self.mnemonic {
                self.checkMnemonic = true
                break;
            }
        }
        if checkMnemonic {
            EZAlertController.alert("", message: "This signature has been created".localizedString() + "." +  "Please try again".localizedString() + ".", acceptMessage: "OK".localizedString()) {
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            if bSignerServiceManager.sharedInstance.checkStatus {
                pushToLockScreenViewController(delegate: self, isCreateAccount: true)
            } else {
                if isAddAcount {
                    
                    HUD.show(.labeledProgress(title: nil, subtitle: "Loading..."))
                    DispatchQueue.global(qos: .background).async {
                        let publickey = MnemonicHelper.getKeyPairFrom(self.mnemonic).accountId
                        self.index += 1
                        self.model.append(SignatureModel.init(title: "Signature".localizedString() + " " + "\(self.index)", publicKey: publickey, mnemonic:self.mnemonic))
                        let data = NSKeyedArchiver.archivedData(withRootObject: self.model)
                        DispatchQueue.main.async {
                            if publickey != ""
                            { bSignerServiceManager.sharedInstance.taskGetSubscribeSignature(userId: bSignerServiceManager.sharedInstance.oneSignalUserId,publicKey: publickey).continueOnSuccessWith(continuation: { task in
                                    HUD.hide()
                                KeychainWrapper.standard.set(data, forKey: "SIGNATURE")
                                KeychainWrapper.standard.set(self.index, forKey: "INDEX")
                                self.showAlertWithText(text: "Create signature success".localizedString())
                                    self.pushMainTabbarViewController()
                                }).continueOnErrorWith(continuation: { error in
                                    HUD.hide()
                                self.navigationController?.popToRootViewController(animated: true)
                                    self.showAlertWithText(text: "Some thing went wrong".localizedString() + ". " + "Please try again".localizedString() + ".")
                                })
                            }
                        }
                    }
                } else {
                    pushToLockScreenViewController(delegate: self, isCreateAccount: true)
                }
            }
        }
    }
}
extension RestoreAccountViewController: MnemonicSuggestionsViewDelegate {
    func suggestionWordWasPressed(_ suggestionWord: String) {
        add(suggestionWord, to: txtMnemonic!.text)
    }
    
}

extension RestoreAccountViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textViewWasChanged(text: textView.text)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

extension RestoreAccountViewController: LockScreenViewControllerDelegate {
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
            pushToLockScreenViewController(delegate: self, passCode: pass,mnemonic: mnemonic, isCreateAccount: true)
        }
    }
}
