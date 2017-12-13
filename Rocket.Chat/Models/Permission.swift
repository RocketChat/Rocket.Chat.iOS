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
    case createPublicChannels = "create-c"
    case createDirectMessages = "create-d"
    case createPrivateChannels = "create-p"

    case viewStatistics = "view-statistics"
    case viewRoomAdministration = "view-room-administration"
    case viewUserAdministration = "view-user-administration"
    case viewPrivilegedSetting = "view-privileged-setting"
}

class Permission: BaseModel {
    var roles = List<String>()
}
