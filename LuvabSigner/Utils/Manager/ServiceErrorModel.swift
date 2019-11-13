//
//  ServiceErrorModel.swift
//  bSigner
//
//  Created by Nguyen Xuan Khang on 11/7/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit
import SwiftyJSON


public class ServiceErrorModel {
        
    class func serviceError(message:String, code:Int, domain:String) -> NSError? {
        
        return NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: message])
        
    }
        
}
