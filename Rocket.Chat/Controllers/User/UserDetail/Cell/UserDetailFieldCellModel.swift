//
//  UserDetailFieldCellModel.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 6/27/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

struct UserDetailFieldCellModel {
    let title: String
    let detail: String
}

extension UserDetailFieldCellModel {
    static var emptyState: UserDetailFieldCellModel {
        return UserDetailFieldCellModel(title: "", detail: "")
    }
}
