//
//  TransactionModel.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 10/22/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit
import SwiftyJSON

enum TransactionType: String {
    case host_transaction = "host_transaction", sign_transaction = "sign_transaction"
}


class TransactionModel: NSObject {
    
    var logId: String = ""
    
    var transactionXDR: String = ""
    
    var amount: String = ""
    
    var note: String = ""
    
    var destUserId: String = ""
    
    var senderUserId: String = ""
    
    var signers: String = ""
    
    var destination: String = ""
    
    var xdr: String = ""
    
    var name: String = ""
            
    var listSignature = Array<JSON>()
    
    var signatureModel:JSON!
    
    var transactionType: TransactionType = .host_transaction
    
    var hosted_at: Double = 0.0

    var low_threshold: Int = 0
    
    var med_threshold: Int = 0
    
    var high_threshold: Int = 0
    
    override init() {
        super.init()
    }

    init(json:JSON) {
        super.init()
        self.logId = json["logId"].stringValue
        self.transactionXDR = json["transactionXDR"].stringValue
        self.amount = json["amount"].stringValue
        self.note = json["note"].stringValue
        self.destUserId = json["destUserId"].stringValue
        self.senderUserId = json["senderUserId"].stringValue
        self.signers = json["signers"].stringValue
        self.destination = json["destination"].stringValue
        self.listSignature = json["signatures"].arrayValue
        self.signatureModel = json["signatures"]
        self.name = json["name"].stringValue
        self.xdr = json["xdr"].stringValue
        self.hosted_at = json["hosted_at"].doubleValue
        self.low_threshold = json["low_threshold"].intValue
        self.med_threshold = json["med_threshold"].intValue
        self.high_threshold = json["high_threshold"].intValue
    }
}
