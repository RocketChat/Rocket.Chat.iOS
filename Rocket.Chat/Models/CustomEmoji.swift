//
//  CustomEmoji.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 1/2/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

class CustomEmoji: BaseModel {
    @objc dynamic var name: String?
    var aliases = List<String>()
    @objc dynamic var ext: String?
}

extension CustomEmoji: ModelMappeable {
    func map(_ values: JSON, realm: Realm?) {
        if identifier == nil {
            identifier = values["_id"].string
        }

        if let aliases = values["aliases"].array?.flatMap({ $0.string }) {
            self.aliases.removeAll()
            self.aliases.append(contentsOf: aliases)
        }

        name = values["name"].stringValue
        ext = values["extension"].stringValue
    }
}
