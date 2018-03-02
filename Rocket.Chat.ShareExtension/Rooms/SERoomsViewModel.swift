//
//  SERoomsViewModel.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 2/28/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

enum SERoomsSectionType {
    case favorites
    case channels
    case groups
    case directMessages
}

struct SERoomsSection {
    let type: SERoomsSectionType
    let roomCells: [SERoomCell]

    var title: String {
        return localized("rooms.section.\(String(describing: self.type))")
    }
}

struct SERoomCell {
    let title: String
}

struct SERoomsViewModel {
    let title: String
    let sections: [SERoomsSection]

    func withTitle(_ title: String) -> SERoomsViewModel {
        return SERoomsViewModel(title: title, sections: sections)
    }

    static var emptyState: SERoomsViewModel {
        return SERoomsViewModel(title: "Error", sections: [])
    }
}

extension SERoomsViewModel {
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

    func cellForRowAt(_ indexPath: IndexPath) -> SERoomCell {
        return sections[indexPath.section].roomCells[indexPath.row]
    }

    func titleForHeaderInSection(_ section: Int) -> String {
        return sections[section].title
    }
}
