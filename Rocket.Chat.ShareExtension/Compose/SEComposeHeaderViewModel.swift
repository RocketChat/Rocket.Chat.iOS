//
//  SEComposeViewModel.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/7/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

struct SEComposeHeaderViewModel {
    let destinationText: String
    let doneButtonEnabled: Bool

    var destinationToText: String {
        return localized("compose.to")
    }

    var title: String {
        return localized("compose.title")
    }

    var doneButtonTitle: String {
        return localized("compose.send")
    }
}

// MARK: SEState

extension SEComposeHeaderViewModel {
    init(state: SEState) {
        doneButtonEnabled = !state.content.contains(where: {
            if case .sending = $0.status {
                return true
            }

            return false
        })

        let symbol: String
        switch state.currentRoom.type {
        case .channel:
            symbol = "#"
        case .group:
            symbol = "#"
        case .directMessage:
            symbol = "@"
        }

        destinationText = "\(symbol)\(state.currentRoom.name)"
    }
}
