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
    
    var logId:String = ""
    
    var transactionXDR:String = ""
    
    var amount:String = ""
    
    var note:String = ""
    
    var destUserId:String = ""
    
    var senderUserId:String = ""
    
    init(json:JSON) {
        super.init()
        self.logId = json["logId"].stringValue
        self.transactionXDR = json["transactionXDR"].stringValue
        self.amount = json["amount"].stringValue
        self.note = json["note"].stringValue
        self.destUserId = json["destUserId"].stringValue
        self.senderUserId = json["senderUserId"].stringValue
    }

}
