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

class BaseModel: Object {
    var mapping: ModelMapping?
    var handler: ModelHandler?

    dynamic var identifier: String?

    override static func primaryKey() -> String? {
        return "identifier"
    }

    convenience init(_ identifier: String) {
        self.init()
    }

    convenience init(dict: JSON) {
        self.init()
        self.mapping?.map(dict)
    }
}
