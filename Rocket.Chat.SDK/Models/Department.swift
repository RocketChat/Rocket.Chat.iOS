//
//  Department.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 5/30/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Livechat Department
public struct Department {
    var id: String
    var enabled: Bool
    var name: String
    var description: String
    var numAgents: Int
    var showOnRegistration: Bool

    init(withJSON json: JSON) {
        id = json["_id"].stringValue
        enabled = json["enabled"].boolValue
        name = json["name"].stringValue
        description = json["description"].stringValue
        numAgents = json["numAgents"].intValue
        showOnRegistration = json["showOnRegistration"].boolValue
    }
}
