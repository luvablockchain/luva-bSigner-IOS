//
//  bSignerServiceManager.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 10/22/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import BoltsSwift


class bSignerServiceManager: NSObject {
    
    public var hostAPI = "https://api.luvapay.com"
    
    public var signTransaction = "/payment/signTransaction"

    public static let sharedInstance : bSignerServiceManager = {
        let instance = bSignerServiceManager()
        return instance
    }()
    
    public func taskSignTransaction(logId:String, signerPublicKey: String,signature: String, token: String ) -> Task<AnyObject> {
        
        let taskCompletionSource = TaskCompletionSource<AnyObject>()
        let stringPath = String(format:"%@%@", hostAPI,signTransaction)
        let parameter = ["logId":logId, "signerPublicKey":signerPublicKey, "signature":signature] as [String: Any]
        let headers: HTTPHeaders = [ "Authorization":"bearer " + token]
        Alamofire.request(stringPath, method: .post,parameters: parameter, headers: headers).validate().responseJSON { response in
            print(response)
            let responseServiceModel = bSignerReponseServiceModel(response: response)
            if let error = responseServiceModel.error as NSError? {
                taskCompletionSource.set(error: error)
            } else {
                if let result = responseServiceModel.data as? JSON {
                    //let model = TransactionModel(json: result)
                    //taskCompletionSource.set(result: model as AnyObject)
                }
            }
            taskCompletionSource.tryCancel()
        }
        return taskCompletionSource.task
    }


}
