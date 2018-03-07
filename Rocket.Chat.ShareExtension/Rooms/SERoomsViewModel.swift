//
//  SERoomsViewModel.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 2/28/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

struct SERoomCell: SECell {
    let room: Subscription

    var title: String {
        return room.name
    }
}

enum SERoomsSectionType {
    case server
    case favorites
    case channels
    case groups
    case directMessages
}

struct SERoomsSection {
    let type: SERoomsSectionType
    let cells: [SECell]

    var title: String {
        return localized("rooms.section.\(String(describing: self.type))")
    }
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

// MARK: DataSource

extension SERoomsViewModel {
    var numberOfSections: Int {
        return sections.count
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        switch section {
        case 0..<sections.count:
            return sections[section].cells.count
        default:
            return 0
        }
    }

    func cellForRowAt(_ indexPath: IndexPath) -> SECell {
        return sections[indexPath.section].cells[indexPath.row]
    }

    func heightForRowAt(_ indexPath: IndexPath) -> Double {
        switch cellForRowAt(indexPath) {
        case is SEServerCellViewModel:
            return 48.0
        case is SERoomCell:
            return 36.0
        default:
            return 36.0
        }
    }

    func titleForHeaderInSection(_ section: Int) -> String {
        return sections[section].title
    }
}

// MARK: Delegate

extension SERoomsViewModel {
    func didSelectRowAt(_ indexPath: IndexPath) {
        let cell = cellForRowAt(indexPath)

        if cell as? SEServerCellViewModel != nil {
            store.dispatch(.makeSceneTransition(.push(.servers)))
        } else if let roomCell = cell as? SERoomCell {
            store.dispatch(.makeSceneTransition(.push(.compose)))
            store.dispatch(.setCurrentRoom(roomCell.room))
        }
    }
}
