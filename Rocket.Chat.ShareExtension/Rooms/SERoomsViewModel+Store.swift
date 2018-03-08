//
//  SERoomsViewModel+Store.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

extension SERoomsViewModel {
    init(state: SEState) {
        let server = state.servers[state.selectedServerIndex]

        let roomToCell = { (room: Subscription) -> SERoomCellModel in
            SERoomCellModel(room: room, avatarBaseUrl: "https://\(server.host)/avatar")
        }

        let favorites = state.displayedRooms.filter { $0.favorite }.map(roomToCell)
        let channels = state.displayedRooms.filter { $0.type == .channel }.map(roomToCell)
        let groups = state.displayedRooms.filter { $0.type == .group }.map(roomToCell)
        let directMessages = state.displayedRooms.filter { $0.type == .directMessage }.map(roomToCell)

        sections = [
            SERoomsSection(type: .server, cells: [
                SEServerCellModel(iconUrl: server.iconUrl, name: server.name, host: server.host, selected: false)
            ]),
            SERoomsSection(type: .favorites, cells: favorites),
            SERoomsSection(type: .channels, cells: channels),
            SERoomsSection(type: .groups, cells: groups),
            SERoomsSection(type: .directMessages, cells: directMessages)
        ].filter { !$0.cells.isEmpty }

        title = localized("rooms.title")
    }
}
