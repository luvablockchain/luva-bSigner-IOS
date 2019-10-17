//
//  SignnatureModel.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 10/10/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit

class SignnatureModel: NSObject, NSCoding {
        
    
    var title:String?
    var publicKey:String?
    
    override init() {
        super.init()
    }
    
    init(title:String, publicKey:String) {
        super.init()
        self.title = title
        self.publicKey = publicKey
    }
    
    required convenience init(coder decoder: NSCoder) {
        self.init()
        self.title = decoder.decodeObject(forKey: "title") as? String
        self.publicKey = decoder.decodeObject(forKey: "publicKey") as? String
    }
    
    
    func encode(with coder: NSCoder) {
        if let title = title { coder.encode(title, forKey: "title") }
        if let publicKey = publicKey { coder.encode(publicKey, forKey: "publicKey") }
    }

}
