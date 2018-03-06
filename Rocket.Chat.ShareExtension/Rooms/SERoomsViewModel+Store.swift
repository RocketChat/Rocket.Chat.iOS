//
//  SERoomsViewModel+Store.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

extension SERoomsViewModel {
    init(store: SEStore) {
        let server = store.servers[store.selectedServerIndex]

        let favorites = store.rooms.filter { $0.favorite }.map(SERoomCell.init)
        let channels = store.rooms.filter { $0.type == .channel }.map(SERoomCell.init)
        let groups = store.rooms.filter { $0.type == .group }.map(SERoomCell.init)
        let directMessages = store.rooms.filter { $0.type == .directMessage }.map(SERoomCell.init)

        sections = [
            SERoomsSection(type: .server, cells: [
                SEServerCell(title: server.name, detail: server.host, selected: false)
            ]),
            SERoomsSection(type: .favorites, cells: favorites),
            SERoomsSection(type: .channels, cells: channels),
            SERoomsSection(type: .groups, cells: groups),
            SERoomsSection(type: .directMessages, cells: directMessages)
        ].filter { !$0.cells.isEmpty }

        title = localized("rooms.title")
    }
}
