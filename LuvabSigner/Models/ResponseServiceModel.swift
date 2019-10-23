//
//  ResponseServiceModel.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 10/22/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

public class ResponseServiceModel: NSObject {

    var status: Int = 0
    var message: String?
    var result: AnyObject?
    var totalItems: Int = 0
    var totalPages: Int = 0
    
    init(json: JSON) {
        super.init()
        self.status = json["status"].int ?? 0
        self.message = json["message"].string ?? ""
        self.result = json["result"].string as AnyObject?
        self.totalItems = json["total_items"].int ?? 0
        self.totalPages = json["total_pages"].int ?? 0
    }
    
    init(response: DataResponse<Any>) {
        super.init()
        
        switch response.result {
        case .success:
            if let value = response.result.value {
                let json = JSON(value)
                if json["status"].int == 400 {
                    self.status = json["status"].int!
                    self.message = json["message"].string ?? ""
                    self.totalItems = json["total_items"].int ?? 0
                    self.totalPages = json["total_pages"].int ?? 0
                    self.result = ServiceErrorModel.serviceError(json: json)
                    
                } else {
                    self.status = json["status"].int ?? 0
                    self.message = json["message"].string ?? ""
                    self.totalItems = json["total_items"].int ?? 0
                    self.totalPages = json["total_pages"].int ?? 0
                    self.result = json.dictionaryValue["result"] as AnyObject?
                }
                
            }
        case .failure(let error):
            self.status = 400
            self.message = ""
            self.result = error as AnyObject?
        }
 
    }
}
