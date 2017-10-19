//
//  RoleField.swift
//  Rocket.Chat
//
//  Created by Vadym Brusko on 10/4/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

class TextField: CustomField {
    override class var type: String {
        return "text"
    }
    @objc dynamic var minLength: Int = 0
    @objc dynamic var maxLength: Int = 10

    override func map(_ values: JSON, realm: Realm?) {
        minLength = values["minLength"].intValue
        maxLength = values["maxLength"].intValue
        super.map(values, realm: realm)
    }
}
