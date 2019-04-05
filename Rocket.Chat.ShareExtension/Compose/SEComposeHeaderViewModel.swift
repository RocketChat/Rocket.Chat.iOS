//
//  SEComposeViewModel.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/7/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

enum DoneButtonState {
    case send
    case cancel
}

struct SEComposeHeaderViewModel {
    let destinationText: String
    let showsActivityIndicator: Bool
    let doneButtonState: DoneButtonState
    let backButtonEnabled: Bool

    var destinationToText: String {
        return localized("compose.to")
    }

    var title: String {
        return localized("compose.title")
    }

    var doneButtonTitle: String {
        switch doneButtonState {
        case .send:
            return localized("compose.send")
        case .cancel:
            return localized("compose.cancel")
        }
    }

    static var emptyState: SEComposeHeaderViewModel {
        return SEComposeHeaderViewModel(
            destinationText: "",
            showsActivityIndicator: false,
            doneButtonState: .send,
            backButtonEnabled: true
        )
    }
}

// MARK: SEState

extension SEComposeHeaderViewModel {
    init(state: SEState) {
        showsActivityIndicator = state.isSubmittingContent
        doneButtonState = showsActivityIndicator ? .cancel : .send
        backButtonEnabled = !showsActivityIndicator

        if state.currentRoom.isDiscussion {
            destinationText = state.currentRoom.fname
        } else {
            let symbol: String
            switch state.currentRoom.type {
            case .channel, .group:
                symbol = "#"
            case .directMessage:
                symbol = "@"
            }

            destinationText = "\(symbol)\(state.currentRoom.name)"
        }
    }

}
