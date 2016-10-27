//
//  AuthSettings.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 06/10/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class AuthSettings: BaseModel {
    dynamic var siteURL: String?
    
    
    // MARK: ModelMapping
    
    fileprivate func objectForKey(object: JSON, key: String) -> JSON? {
        for obj in object.array! {
            if obj["_id"].string == key {
                return obj["value"]
            }
        }
        
        return nil
    }
    
    override func update(_ dict: JSON) {
        if self.identifier == nil {
            self.identifier = String.random()
        }
        
        self.siteURL = objectForKey(object: dict, key: "Site_Url")?.string
        
    }
}
