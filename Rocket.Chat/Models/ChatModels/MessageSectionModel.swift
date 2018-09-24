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
    let daySeparator: Date?
    let isLoadingMore: Bool
    let isNew: Bool

    init(message: UnmanagedMessage, daySeparator: Date?, isLoadingMore: Bool, isNew: Bool) {
        self.identifier = message.identifier
        self.message = message
        self.daySeparator = daySeparator
        self.isLoadingMore = isLoadingMore
        self.isNew = isNew
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
