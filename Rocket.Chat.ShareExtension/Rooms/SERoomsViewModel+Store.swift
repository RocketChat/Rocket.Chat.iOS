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
        let (favorites, channels, groups, directMessages) = store.rooms

        sections = [
            SERoomsSection(type: .server, cells: [
                SEServerCell(title: server.name, detail: server.host, selected: false)
            ]),
            SERoomsSection(type: .favorites, cells: favorites.map { SERoomCell(title: $0) }),
            SERoomsSection(type: .channels, cells: channels.map { SERoomCell(title: $0) }),
            SERoomsSection(type: .groups, cells: groups.map { SERoomCell(title: $0) }),
            SERoomsSection(type: .directMessages, cells: directMessages.map { SERoomCell(title: $0) })
        ]

        title = localized("rooms.title")
    }
}
