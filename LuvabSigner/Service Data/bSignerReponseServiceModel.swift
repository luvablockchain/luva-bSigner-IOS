//
//  bSignerReponseServiceModel.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 10/22/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit

import SwiftyJSON
import Alamofire

class bSignerReponseServiceModel: NSObject {
    
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
                if (self.errorCode == 0 || self.errorCode == 1) {
                    self.data = json.dictionaryValue["data"] as AnyObject?
                } else {
                    self.error = ServiceErrorModel.serviceError(message: json["error"].stringValue, code: self.errorCode, domain: "ChatCoreResponseServiceModel")
                }
                
            }
        case .failure(let error):
            self.error = error
        }
        
    }

}
