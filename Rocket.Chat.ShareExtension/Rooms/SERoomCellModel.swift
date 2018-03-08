//
//  SERoomCellViewModel.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/7/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

struct SERoomCellModel: SECellModel {
    let room: Subscription
    let avatarBaseUrl: String

    var name: String {
        return room.name
    }
}
