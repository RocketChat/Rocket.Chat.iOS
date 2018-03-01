//
//  SEServersViewModel+Store.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

extension SEServersViewModel {
    init(store: SEStore) {
        serverCells = store.servers.enumerated().map {
            SEServerCell(title: $1, selected: store.selectedServer == $0)
        }
    }
}
