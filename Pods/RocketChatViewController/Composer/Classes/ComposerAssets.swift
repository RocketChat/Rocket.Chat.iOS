//
//  ComposerAssets.swift
//  RocketChatViewController Example
//
//  Created by Matheus Cardoso on 9/5/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

private var bundle = Bundle(for: ComposerView.self)

private func imageNamed(_ name: String) -> ComposerAsset<UIImage> {
    let image = UIImage(named: name, in: bundle, compatibleWith: nil)
    return ComposerAsset(image ?? UIImage())
}

private var addButtonImage = imageNamed("Add Button")
private var sendButtonImage = imageNamed("Send Button")
private var micButtonImage = imageNamed("Mic Button")

private var cancelReplyButtonImage = imageNamed("Cancel Reply Button")

public struct ComposerAsset<T> {
    let raw: T
    init(_ raw: T) {
        self.raw = raw
    }
}

public extension ComposerAsset where T == UIImage {
    public static var addButton: ComposerAsset<T> {
        return addButtonImage
    }

    public static var sendButton: ComposerAsset<T> {
        return sendButtonImage
    }

    public static var micButton: ComposerAsset<T> {
        return micButtonImage
    }

    public static var cancelReplyButton: ComposerAsset<T> {
        return cancelReplyButtonImage
    }
}
