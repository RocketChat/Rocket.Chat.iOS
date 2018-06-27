//
//  UserDetailViewModel.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 6/26/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

struct UserDetailViewModel {
    var cells: [UserDetailFieldCellModel]
}

// MARK: Empty State

extension UserDetailViewModel {
    static var emptyState: UserDetailViewModel {
        return UserDetailViewModel(
            cells: [
                UserDetailFieldCellModel(title: "Role", detail: "Product Designer"),
                UserDetailFieldCellModel(title: "Email", detail: "victoria.anderson@rocket.chat"),
                UserDetailFieldCellModel(title: "Phone number", detail: "+1 (408) 568-4583"),
                UserDetailFieldCellModel(title: "Timezone", detail: "(GMT +3) 12:41 PM")
            ]
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
        return indexPath.section == 0 && indexPath.row < cells.count ? cells[indexPath.row] : .emptyState
    }
}
