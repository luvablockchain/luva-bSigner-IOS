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

class bSignerServiceManager: NSObject {
    
    private let hostAPI = ""
    
    private let subscribe = "/subscribe"
    
    private let transactionList = "/transaction/list"
    
    private let addSignature = "/transaction/addSignature"
    
    public var oneSignalUserId = ""
    
    public static let sharedInstance : bSignerServiceManager = {
        let instance = bSignerServiceManager()
        return instance
    }()
    
    public func taskGetSubscribeSignature(publicKey: String, userId: String) -> Task<AnyObject> {
        let taskCompletionSource = TaskCompletionSource<AnyObject>()
        let stringPath = String(format:"%@%@", hostAPI, subscribe)
        let parameter = ["public_key":publicKey,"user_id":userId] as [String: Any]
        Alamofire.SessionManager.default.request(stringPath, method: .post,parameters: parameter).validate().responseJSON { (response) in
            if let error = response.error {
                taskCompletionSource.set(error: error)
            } else {
                taskCompletionSource.set(result: true as AnyObject)
            }
            taskCompletionSource.tryCancel()
        }
        return taskCompletionSource.task
    }
    
    public func taskGetTransactionList(signer: String, userId: String) -> Task<AnyObject> {
        let taskCompletionSource = TaskCompletionSource<AnyObject>()
        let stringPath = String(format:"%@%@", hostAPI, transactionList)
        let parameter = ["signer_keys":signer,"user_id":userId] as [String: Any]
        Alamofire.SessionManager.default.request(stringPath, method: .post,parameters: parameter).validate().responseJSON { (response) in
            if let error = response.error {
                taskCompletionSource.set(error: error)
            } else {
                taskCompletionSource.set(result: true as AnyObject)
            }
            taskCompletionSource.tryCancel()
        }
        return taskCompletionSource.task
    }
    
    public func taskGetAddSignature(userId: String, transactionXDR: String, publicKey: String, signature: String) -> Task<AnyObject> {
        let taskCompletionSource = TaskCompletionSource<AnyObject>()
        let stringPath = String(format:"%@%@", hostAPI, addSignature)
        let parameter = ["user_id":userId,"transaction_xdr":transactionXDR, "public_key":publicKey, "signature": signature] as [String: Any]
        Alamofire.SessionManager.default.request(stringPath, method: .post,parameters: parameter).validate().responseJSON { (response) in
            if let error = response.error {
                taskCompletionSource.set(error: error)
            } else {
                taskCompletionSource.set(result: true as AnyObject)
            }
            taskCompletionSource.tryCancel()
        }
        return taskCompletionSource.task
    }



}
