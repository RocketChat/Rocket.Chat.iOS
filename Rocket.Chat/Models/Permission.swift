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

    case deleteMessage = "delete-message"
    case forceDeleteMessage = "force-delete-message"

    case editMessage = "edit-message"

    case pinMessage = "pin-message"

    case postReadOnly = "post-readonly"

    case removeUser = "remove-user"
}

class Permission: BaseModel {
    var roles = List<String>()
}
