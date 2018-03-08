//
//  SEServersViewModel+Store.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

extension SEServersViewModel {
    init(state: SEState) {
        serverCells = state.servers.enumerated().map {
            SEServerCellModel(
                iconUrl: $1.iconUrl,
                name: $1.name,
                host: $1.host,
                selected: state.selectedServerIndex == $0
            )
        }
    }
}
