//
//  SERoomsViewModel.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 2/28/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

enum SERoomsSectionType {
    case server
    case favorites
    case channels
    case groups
    case directMessages
}

struct SERoomsSection {
    let type: SERoomsSectionType
    let cells: [SECellModel]

    var title: String {
        return localized("rooms.section.\(String(describing: self.type))")
    }
}

struct SERoomsViewModel {
    let title: String
    let sections: [SERoomsSection]
    let searchText: String

    static var emptyState: SERoomsViewModel {
        return SERoomsViewModel(title: "Error", sections: [], searchText: "")
    }
}

// MARK: SEState

extension SERoomsViewModel {
    init(state: SEState) {
        switch state.searchRooms {
        case .none:
            searchText = ""
        case .started:
            searchText = ""
        case .searching(let text):
            searchText = text
        }

        let server = state.servers[state.selectedServerIndex]

        let roomToCell = { (room: Subscription) -> SERoomCellModel in
            SERoomCellModel(room: room, avatarBaseUrl: "\(server.host)/avatar")
        }

        let favorites = state.displayedRooms.filter { $0.favorite }.sorted {
            ($0.type.rawValue, $0.name.lowercased()) < ($1.type.rawValue, $1.name.lowercased())
        }.map(roomToCell)

        let channels = state.displayedRooms.filter { $0.type == .channel }.map(roomToCell)
        let groups = state.displayedRooms.filter { $0.type == .group }.map(roomToCell)
        let directMessages = state.displayedRooms.filter { $0.type == .directMessage }.map(roomToCell)

        let serverCell = SEServerCellModel(iconUrl: server.iconUrl, name: server.name, host: server.host, selected: false)
        let serverSection = searchText.isEmpty ? [SERoomsSection(type: .server, cells: [serverCell])] : []

        sections = serverSection + [
            SERoomsSection(type: .favorites, cells: favorites),
            SERoomsSection(type: .channels, cells: channels),
            SERoomsSection(type: .groups, cells: groups),
            SERoomsSection(type: .directMessages, cells: directMessages)
        ].filter { !$0.cells.isEmpty }

        title = localized("rooms.title")
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

    func cellForRowAt(_ indexPath: IndexPath) -> SECellModel {
        return sections[indexPath.section].cells[indexPath.row]
    }

    func heightForRowAt(_ indexPath: IndexPath) -> Double {
        switch cellForRowAt(indexPath) {
        case is SEServerCellModel:
            return 60.0
        case is SERoomCellModel:
            return 44.0
        default:
            return 44.0
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

        if cell as? SEServerCellModel != nil {
            store.dispatch(.makeSceneTransition(.push(.servers)))
        } else if let roomCell = cell as? SERoomCellModel {
            store.dispatch(.makeSceneTransition(.push(.compose)))
            store.dispatch(.setCurrentRoom(roomCell.room))
        }
    }
}
