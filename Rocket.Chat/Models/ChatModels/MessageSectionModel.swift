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

    var daySeparator: Date? = nil
    var isSequential: Bool = false

    var containsLoader: Bool = false
    var containsUnreadMessageIndicator: Bool = false
    var containsDateSeparator: Bool { return daySeparator != nil }

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
            containsLoader == source.containsLoader &&
            containsUnreadMessageIndicator == source.containsUnreadMessageIndicator &&
            isSequential == source.isSequential
    }
}
