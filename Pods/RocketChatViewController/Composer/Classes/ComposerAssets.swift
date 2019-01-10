//
//  ComposerAssets.swift
//  RocketChatViewController Example
//
//  Created by Matheus Cardoso on 9/5/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

public struct ComposerAssets {
    public static let addButtonImage = imageNamed("Add Button")
    public static let sendButtonImage = imageNamed("Send Button")
    public static let micButtonImage = imageNamed("Mic Button")

    public static let cancelReplyButtonImage = imageNamed("Cancel Reply Button")

    private static let bundle = Bundle(for: ComposerView.self)

    private static func imageNamed(_ name: String) -> UIImage {
        let image = UIImage(named: name, in: bundle, compatibleWith: nil)
        return image ?? UIImage()
    }
}
