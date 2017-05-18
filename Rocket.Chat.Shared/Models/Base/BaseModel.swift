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

public class BaseModel: Object {
    dynamic var identifier: String?

    override public static func primaryKey() -> String? {
        return "identifier"
    }
}
