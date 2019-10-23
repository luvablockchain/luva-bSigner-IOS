//
//  ServiceErrorModel.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 10/22/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit
import SwiftyJSON

enum ServiceError: Int {
    case ServiceErrorGraphQL = 1,
    ServiceErrorRest = 2, success = 0, permission = 100, exist = 101, notExist = 102, parameter = 103, externalService = 109, other = 110, database = 115
}

public class ServiceErrorModel {
    
    class func serviceError(responseServiceModel: ResponseServiceModel) -> NSError? {
        
        return ErrorModel(domain: "serviceError", code: responseServiceModel.status, message: responseServiceModel.message ?? "", result: responseServiceModel.result as? JSON)
        
    }
    
    class func serviceError(json: JSON) -> NSError? {
        let responseServiceModel = ResponseServiceModel(json: json)
        
        return ErrorModel(domain: "serviceError", code: responseServiceModel.status, message: responseServiceModel.message ?? "", result: json.dictionaryValue["result"])
        
    }
    
    
    class func serviceErrorGraphQL(json: JSON, domain: String) -> NSError? {

        return NSError(domain: domain, code: ServiceError.ServiceErrorGraphQL.rawValue, userInfo: [NSLocalizedDescriptionKey: json["errors"][0]["message"].string!])
      
    }
    
    class func serviceError(json:JSON, domain:String) -> NSError? {
 
        return NSError(domain: domain, code: json["ErrorCode"].int!, userInfo: [NSLocalizedDescriptionKey: json["Message"].string!])

    }
    
    class func serviceError(message:String, code:Int, domain:String) -> NSError? {
        
        return NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: message])
        
    }
    
    class func serviceError(messageError:String, domain:String) -> NSError? {
        
        return NSError(domain: domain, code: -1, userInfo: [NSLocalizedDescriptionKey: messageError])
        
        
    }
    
    
}

public class ErrorModel: NSError {
    
    var result: JSON?
    
    init(domain: String, code: Int, message: String, result: JSON?) {
        var dict: [String: String]!
        var message = message
        if let result = result, let dictionary = result.dictionary {
            for d in dictionary {
                message = String(format: "\n%@\n%@ : %@", message, d.key, d.value.string ?? "")
            }

        }
        dict = [NSLocalizedDescriptionKey: message]
        super.init(domain: domain, code: code, userInfo: dict)
        self.result = result
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
