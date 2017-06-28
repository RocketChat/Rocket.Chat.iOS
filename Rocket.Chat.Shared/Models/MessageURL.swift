//
//  MessageURL.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 17/10/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

/// A data structure represents a url message's preview data
public class MessageURL: BaseModel {
    dynamic var textDescription: String?
    dynamic var title: String?
    dynamic var targetURL: String?
    dynamic var imageURL: String?

    func isValid() -> Bool {
        return title?.characters.count ?? 0 > 0 && textDescription?.characters.count ?? 0 > 0
    }
}
