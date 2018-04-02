//
//  ChatMessageCellAccessibility.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 3/26/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

// MARK: Accessibility

extension ChatMessageCell {
    override func awakeFromNib() {
        super.awakeFromNib()

        isAccessibilityElement = true
    }

    override var accessibilityIdentifier: String? {
        get { return "message" }
        set { }
    }

    override var accessibilityLabel: String? {
        get { return message?.accessibilityLabel }
        set { }
    }

    override var accessibilityValue: String? {
        get { return message?.accessibilityValue }
        set { }
    }

    override var accessibilityHint: String? {
        get { return message?.accessibilityHint }
        set { }
    }

}
