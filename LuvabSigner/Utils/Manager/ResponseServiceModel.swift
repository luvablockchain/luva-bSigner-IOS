//
//  ResponseServiceModel.swift
//  bSigner
//
//  Created by Nguyen Xuan Khang on 11/7/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class ResponseServiceModel: NSObject {
    
    var data: AnyObject?
    
    var errorCode: Int = -1
    
    var error: Error?
    
    
    init(response: DataResponse<Any>) {
        super.init()
        
        switch response.result {
        case .success:
            if let value = response.result.value {
                let json = JSON(value)
                self.errorCode = json["errorCode"].intValue
                if (self.errorCode == 0) {
                    self.data = json.dictionaryValue["data"] as AnyObject?
                    
                } else {
                    self.error = ServiceErrorModel.serviceError(message: json["error"].stringValue, code: self.errorCode, domain: "Error")
                }
                
            }
        case .failure(let error):
            self.error = error
        }
        
    }

}
