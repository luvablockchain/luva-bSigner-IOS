//
//  TransactionModel.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 10/22/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit
import SwiftyJSON

class TransactionModel: NSObject {
    
    var logId: String = ""
    
    var transactionXDR: String = ""
    
    var amount: String = ""
    
    var note: String = ""
    
    var destUserId: String = ""
    
    var senderUserId: String = ""
    
    var signers: String = ""
    
    var destination: String = ""
    
    var transaction_xdr: String = ""
    
    var transaction_name: String = ""
    
    var signatures = Array<String>()

    
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
        if let array = json["signatures"].array {
            for item in array {
                signatures.append(item.string ?? "")
            }
        }
        self.transaction_xdr = json["transaction_xdr"].stringValue
        self.transaction_name = json["transaction_name"].stringValue
    }

}
