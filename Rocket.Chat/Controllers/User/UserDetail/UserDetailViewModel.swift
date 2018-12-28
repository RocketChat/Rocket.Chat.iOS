//
//  UserDetailViewModel.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 6/26/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

struct UserDetailViewModel {
    let name: String
    let username: String
    let avatarUrl: URL?
    let cells: [UserDetailFieldCellModel]

    let messageButtonText = localized("user_details.message_button")
    let voiceCallButtonText = localized("user_details.voice_call_button")
    let videoCallButtonText = localized("user_details.video_call_button")
}

// MARK: Empty State

extension UserDetailViewModel {
    static var emptyState: UserDetailViewModel {
        return UserDetailViewModel(name: "", username: "", avatarUrl: nil, cells: [])
    }
}

// MARK: User

extension UserDetailViewModel {
    static func forUser(_ user: User) -> UserDetailViewModel {
        return UserDetailViewModel(
            name: user.name ?? user.username ?? "",
            username: user.username ?? "",
            avatarUrl: user.avatarURL(),
            cells: UserDetailFieldCellModel.cellsForUser(user)
        )
    }
}

// MARK: Table View

extension UserDetailViewModel {
    var numberOfSections: Int {
        return 1
    }

    func numberOfRowsForSection(_ section: Int) -> Int {
        return section == 0 ? cells.count : 0
    }

    func cellForRowAtIndexPath(_ indexPath: IndexPath) -> UserDetailFieldCellModel {
        return
            indexPath.section == 0 &&
            indexPath.row < cells.count ? cells[indexPath.row] : .emptyState
    }
}
