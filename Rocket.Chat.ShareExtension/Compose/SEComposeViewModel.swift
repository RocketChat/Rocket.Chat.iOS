//
//  SEComposeViewModel.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/7/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

struct SEComposeViewModel {
    let composeText: String
    let destinationText: String

    var destinationToText: String {
        return localized("compose.to")
    }

    var title: String {
        return localized("compose.title")
    }
}

// MARK: SEState

extension SEComposeViewModel {
    init(state: SEState) {
        composeText = state.composeText
        destinationText = state.currentRoom.name
    }
}
