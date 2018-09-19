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
    let message: Message

    init(identifier: String, message: Message) {
        self.identifier = identifier
        self.message = message
    }

    // MARK: Differentiable

    var differenceIdentifier: String {
        return identifier
    }

    func isContentEqual(to source: MessageSectionModel) -> Bool {
        return message.text == source.message.text
    }
}
