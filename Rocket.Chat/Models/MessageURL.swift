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

class MessageURL: BaseModel {
    @objc dynamic var textDescription: String?
    @objc dynamic var title: String?
    @objc dynamic var targetURL: String?
    @objc dynamic var imageURL: String?

    func isValid() -> Bool {
        return title?.count ?? 0 > 0 && textDescription?.count ?? 0 > 0
    }
}
