//
//  SERoomsViewModel+Store.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

extension SERoomsViewModel {
    init(store: SEStore) {
        sections = [
            SERoomsSection(type: .favorites, roomCells: [
                SERoomCell(title: "@matheus.cardoso"),
                SERoomCell(title: "#general"),
                SERoomCell(title: "#important")
            ]),
            SERoomsSection(type: .channels, roomCells: [
                SERoomCell(title: "#general")
            ]),
            SERoomsSection(type: .groups, roomCells: [
                SERoomCell(title: "#ios-dev-internal"),
                SERoomCell(title: "#important")
            ]),
            SERoomsSection(type: .directMessages, roomCells: [
                SERoomCell(title: "@matheus.cardoso"),
                SERoomCell(title: "@rafael.kellermann"),
                SERoomCell(title: "@filipe.alvarenga"),
                SERoomCell(title: "@rocket.chat")
            ])
        ]

        if store.selectedServerIndex < store.servers.count {
            title = store.servers[store.selectedServerIndex].host
        } else {
            title = "No servers"
        }
    }
}
