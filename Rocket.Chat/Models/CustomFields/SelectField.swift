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

class SelectField: CustomField {
    override class var type: String {
        return "select"
    }

    var options: [String] = []
    @objc dynamic var defaultValue: String = ""

    override func map(_ values: JSON, realm: Realm?) {
        options = values["options"].arrayValue.map { $0.stringValue }
        defaultValue = values["defaultValue"].stringValue
        super.map(values, realm: realm)
    }
}
