//
//  bSignerServiceManager.swift
//  bSigner
//
//  Created by Nguyen Xuan Khang on 11/4/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit
import Alamofire
import BoltsSwift
import SwiftyJSON

class bSignerServiceManager: NSObject {
        
    public var hostAPI = "http://bsignerapi.luvapay.com:3000"
    
   // public var hostAPI = "http://10.10.9.57:3000"

    private let subscribe = "/subscribe"
    
    private let unsubscribe = "/unsubscribe"

    private let transactionList = "/transaction/list"
        
    private let signTransaction = "/transaction/sign"
    
    private let updateTransaction = "/transaction/update"
    
    private let hostTransaction = "/transaction/host"
    
    public var oneSignalUserId = ""
    
    public var checkStatus = false
    
    public var isSeenDetails = false
    
    public var isSeenTransactions = false
    
    public var isOpenTransactions = false
    
    public static let sharedInstance : bSignerServiceManager = {
        let instance = bSignerServiceManager()
        return instance
    }()
    
    public func taskGetSubscribeSignature(userId: String, publicKey: String) -> Task<AnyObject> {
        let taskCompletionSource = TaskCompletionSource<AnyObject>()
        let stringPath = String(format:"%@%@", hostAPI, subscribe)
        let parameter = ["user_id":userId, "public_key":publicKey] as [String: Any]
        Alamofire.SessionManager.default.request(stringPath, method: .post,parameters: parameter,encoding:JSONEncoding.default).validate().responseJSON { (response) in
            let responseServiceModel = ResponseServiceModel(response: response)
            if let error = responseServiceModel.error as NSError? {
                taskCompletionSource.set(error: error)
            } else {
                taskCompletionSource.set(result: true as AnyObject)
            }
            taskCompletionSource.tryCancel()
        }
        return taskCompletionSource.task
    }
    
    public func taskGetUnSubscribeSignature(userId: String, publicKey: String) -> Task<AnyObject> {
        let taskCompletionSource = TaskCompletionSource<AnyObject>()
        let stringPath = String(format:"%@%@", hostAPI, unsubscribe)
        let parameter = ["user_id":userId, "public_key":publicKey] as [String: Any]
        Alamofire.SessionManager.default.request(stringPath, method: .post,parameters: parameter,encoding:JSONEncoding.default).validate().responseJSON { (response) in
            let responseServiceModel = ResponseServiceModel(response: response)
            if let error = responseServiceModel.error as NSError? {
                taskCompletionSource.set(error: error)
            } else {
                taskCompletionSource.set(result: true as AnyObject)
            }
            taskCompletionSource.tryCancel()
        }
        return taskCompletionSource.task
    }
    
    public func taskGetTransactionList(publicKeys:[String], userId: String) -> Task<AnyObject> {
        let taskCompletionSource = TaskCompletionSource<AnyObject>()
        let stringPath = String(format:"%@%@", hostAPI, transactionList)
        let parameter = ["public_keys":publicKeys,"user_id":userId] as [String: Any]
        Alamofire.SessionManager.default.request(stringPath, method: .post,parameters: parameter,encoding: JSONEncoding.default).validate().responseJSON { (response) in
            let responseServiceModel = ResponseServiceModel(response: response)
            if let error = responseServiceModel.error as NSError? {
                taskCompletionSource.set(error: error)
            } else {
                let json = JSON(responseServiceModel.data!)
                let transactions = json["transactions"].arrayValue
                    var listTransaction:[TransactionModel] = []
                    for transaction in transactions {
                        let model = TransactionModel(json: transaction)
                        listTransaction.append(model)
                    }
                taskCompletionSource.set(result: listTransaction as AnyObject)
            }
            taskCompletionSource.tryCancel()
        }
        return taskCompletionSource.task
    }
    
    public func taskGetSignTransaction(userId: String, xdr: String, publicKey: String, signature: String) -> Task<AnyObject> {
        let taskCompletionSource = TaskCompletionSource<AnyObject>()
        let stringPath = String(format:"%@%@", hostAPI, signTransaction)
        let signatures = [["public_key":publicKey,"signature":signature]]
        let parameter = ["user_id":userId,"xdr":xdr, "signatures": signatures] as [String: Any]
        Alamofire.SessionManager.default.request(stringPath, method: .post,parameters: parameter,encoding: JSONEncoding.default).validate().responseJSON { (response) in
            let responseServiceModel = ResponseServiceModel(response: response)
            if let error = responseServiceModel.error as NSError? {
                taskCompletionSource.set(error: error)
            } else {
                let json = JSON(responseServiceModel.data!)
                let signatures = json["invalid_signatures"].arrayValue
                    var listSignature:[SignatureModel] = []
                    for signature in signatures {
                        let model = SignatureModel(json: signature)
                        listSignature.append(model)
                    }
                taskCompletionSource.set(result: listSignature as AnyObject)
            }
            taskCompletionSource.tryCancel()
        }
        return taskCompletionSource.task
    }
    
    public func taskUpdateTransaction() -> Task<AnyObject> {
        let taskCompletionSource = TaskCompletionSource<AnyObject>()
        let stringPath = String(format:"%@%@", hostAPI, updateTransaction)
        let parameter = [:] as [String: Any]
        Alamofire.SessionManager.default.request(stringPath, method: .post,parameters: parameter,encoding:JSONEncoding.default).validate().responseJSON { (response) in
            let responseServiceModel = ResponseServiceModel(response: response)
            if let error = responseServiceModel.error as NSError? {
                taskCompletionSource.set(error: error)
            } else {
                taskCompletionSource.set(result: true as AnyObject)
            }
            taskCompletionSource.tryCancel()
        }
        return taskCompletionSource.task
    }

    public func taskGetTransactionHost(xdr: String, signature: String, name:String) -> Task<AnyObject> {
        let taskCompletionSource = TaskCompletionSource<AnyObject>()
        let stringPath = String(format:"%@%@", hostAPI, hostTransaction)
        let parameter = ["xdr":xdr, "signature": signature, "name":name] as [String: Any]
        Alamofire.SessionManager.default.request(stringPath, method: .post,parameters: parameter,encoding: JSONEncoding.default).validate().responseJSON { (response) in
            let responseServiceModel = ResponseServiceModel(response: response)
            if let error = responseServiceModel.error as NSError? {
                taskCompletionSource.set(error: error)
            } else {
                taskCompletionSource.set(result: true as AnyObject)
            }
            taskCompletionSource.tryCancel()
        }
        return taskCompletionSource.task
    }
}
