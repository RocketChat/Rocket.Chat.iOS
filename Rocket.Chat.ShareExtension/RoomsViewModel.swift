//
//  RoomsViewModel.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 2/28/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

enum RoomsSectionType {
    case favorites
    case channels
    case groups
    case directMessages
}

struct RoomsSection {
    let type: RoomsSectionType
    let roomCells: [RoomCell]

    var title: String {
        return localized("rooms.section.\(String(describing: self.type))")
    }
}

struct RoomCell {
    let title: String
}

struct RoomsViewModel {
    let sections: [RoomsSection]
}

extension RoomsViewModel {
    var numberOfSections: Int {
        return sections.count
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        switch section {
        case 0..<sections.count:
            return sections[section].roomCells.count
        default:
            return 0
        }
    }

    func cellForRowAt(_ indexPath: IndexPath) -> RoomCell {
        return sections[indexPath.section].roomCells[indexPath.row]
    }
}
