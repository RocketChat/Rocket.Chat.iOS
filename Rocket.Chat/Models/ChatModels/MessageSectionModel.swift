//
//  MessageSectionModel.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 19/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import DifferenceKit

struct MessageSectionModel: Differentiable {
    let identifier: String
    let message: UnmanagedMessage

    let isSequential: Bool = false
    let isLoadingMore: Bool = false
    let isNew: Bool = false
    let daySeparator: Date?

    init(message: UnmanagedMessage) {
        self.identifier = message.identifier
        self.message = message
    }

    // MARK: Differentiable

    var differenceIdentifier: String {
        return identifier
    }

    func isContentEqual(to source: MessageSectionModel) -> Bool {
        return
            message.isContentEqual(to: source.message) &&
            daySeparator == source.daySeparator &&
            isLoadingMore == source.isLoadingMore &&
            isNew == source.isNew
    }
}
