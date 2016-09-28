//
//  BaseModel.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/8/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

protocol ModelMapping {
    func update(_ dict: JSON)
}

class BaseModel: Object, ModelMapping {
    dynamic var identifier: String?
    
    override static func primaryKey() -> String? {
        return "identifier"
    }
    
    
    // MARK: ModelMapping
    
    convenience init(_ identifier: String) {
        self.init()
    }
    
    convenience init(dict: JSON) {
        self.init()
        self.update(dict)
    }
    
    func update(_ dict: JSON) {}

}

