//
//  CustomField.swift
//  Rocket.Chat
//
//  Created by Vadym Brusko on 10/2/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class CustomField {
    class var type: String {
        return ""
    }

    var name: String = ""
    var required: Bool = false

    func map(_ values: JSON, realm: Realm?) {
        self.required = values["required"].bool ?? false
    }

    static func chooseType(from json: JSON, name: String) -> CustomField {
        var customField: CustomField

        switch json["type"].stringValue {
        case SelectField.type:
            customField = SelectField()
        case TextField.type:
            customField = TextField()
        default:
            customField = CustomField()
        }

        customField.name = name
        return customField
    }
}
