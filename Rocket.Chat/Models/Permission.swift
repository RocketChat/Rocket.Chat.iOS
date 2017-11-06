//
//  Permission.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 11/6/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

enum PermissionType: String {
    case createChannel = "create-c"
    case createDirect = "create-d"
    case createPrivate = "create-p"
}

class Permission: BaseModel {
    var roles = [Role]()
}
