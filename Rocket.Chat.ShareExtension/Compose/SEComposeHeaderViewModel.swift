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
    let showsActivityIndicator: Bool
    let doneButtonEnabled: Bool
    let backButtonEnabled: Bool

    var destinationToText: String {
        return localized("compose.to")
    }

    var title: String {
        return localized("compose.title")
    }

    var doneButtonTitle: String {
        return localized("compose.send")
    }

    static var emptyState: SEComposeHeaderViewModel {
        return SEComposeHeaderViewModel(
            destinationText: "",
            showsActivityIndicator: false,
            doneButtonEnabled: false,
            backButtonEnabled: true
        )
    }
}

// MARK: SEState

extension SEComposeHeaderViewModel {
    init(state: SEState) {
        showsActivityIndicator = state.content.contains(where: {
            if case .sending = $0.status {
                return true
            }

            return false
        })
        doneButtonEnabled = !showsActivityIndicator
        backButtonEnabled = !showsActivityIndicator

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
