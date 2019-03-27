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

    public static let redMicButtonImage = imageNamed("Red Mic Button")
    public static let grayArrowLeftButtonImage = imageNamed("Gray Arrow Left")

    public static let playButtonImage = imageNamed("Play Button")
    public static let pauseButtonImage = imageNamed("Pause Button")
    public static let sliderThumbImage = imageNamed("Slider Thumb")
    public static let discardButtonImage = imageNamed("Discard Button")

    private static let bundle = Bundle(for: ComposerView.self)

    private static func imageNamed(_ name: String) -> UIImage {
        let image = UIImage(named: name, in: bundle, compatibleWith: nil)
        return image ?? UIImage()
    }

    // MARK: Sounds

    public static var startAudioRecordSound: URL? {
        return bundle.url(forResource: "start_audio_record", withExtension: "m4a")
    }

    public static var cancelAudioRecordSound: URL? {
        return bundle.url(forResource: "cancel_audio_record", withExtension: "m4a")
    }
}
