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

        sections = [
            SERoomsSection(type: .server, cells: [
                SEServerCell(title: server.name, detail: server.host, selected: false)
            ]),
            SERoomsSection(type: .favorites, cells: [
                SERoomCell(title: "@matheus.cardoso"),
                SERoomCell(title: "#general"),
                SERoomCell(title: "#important")
            ]),
            SERoomsSection(type: .channels, cells: [
                SERoomCell(title: "#general")
            ]),
            SERoomsSection(type: .groups, cells: [
                SERoomCell(title: "#ios-dev-internal"),
                SERoomCell(title: "#important")
            ]),
            SERoomsSection(type: .directMessages, cells: [
                SERoomCell(title: "@matheus.cardoso"),
                SERoomCell(title: "@rafael.kellermann"),
                SERoomCell(title: "@filipe.alvarenga"),
                SERoomCell(title: "@rocket.chat")
            ])
        ]

        if store.selectedServerIndex < store.servers.count {
            title = store.servers[store.selectedServerIndex].name
        } else {
            title = "No servers"
        }
    }
}
