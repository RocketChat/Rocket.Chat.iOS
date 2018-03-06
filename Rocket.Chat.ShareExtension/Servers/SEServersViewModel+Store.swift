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
            SEServerCell(
                title: $1.name,
                detail: $1.host,
                selected: state.selectedServerIndex == $0
            )
        }
    }
}
