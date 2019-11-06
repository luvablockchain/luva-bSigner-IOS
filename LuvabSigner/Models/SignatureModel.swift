//
//  SignnatureModel.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 10/10/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import UIKit
import SwiftyJSON

class SignatureModel: NSObject, NSCoding {
        
    var title:String?
    
    var publicKey:String?
    
    var mnemonic:String?
    
    var public_key: String = ""
    
    var signature: String = ""
    
    init(json:JSON) {
        super.init()
        self.public_key = json["public_key"].stringValue
        self.signature = json["signature"].stringValue
    }

    override init() {
        super.init()
    }
    
    init(title:String, publicKey:String, mnemonic:String) {
        super.init()
        self.title = title
        self.publicKey = publicKey
        self.mnemonic = mnemonic
    }
    
    required convenience init(coder decoder: NSCoder) {
        self.init()
        self.title = decoder.decodeObject(forKey: "title") as? String
        self.publicKey = decoder.decodeObject(forKey: "publicKey") as? String
        self.mnemonic = decoder.decodeObject(forKey: "mnemonic") as? String
    }
    
    
    func encode(with coder: NSCoder) {
        if let title = title { coder.encode(title, forKey: "title") }
        if let publicKey = publicKey { coder.encode(publicKey, forKey: "publicKey") }
        if let mnemonic = mnemonic { coder.encode(mnemonic, forKey: "mnemonic") }
    }

}
