//
//  DrawingViewModel.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 13.02.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

final class DrawingViewModel {
    internal static let defaultBrushColor: UIColor = .black

    internal static let defaultBrushWidth: CGFloat = 10.0

    internal static let defaultBrushOpacity: CGFloat = 1.0

    internal var title: String {
        return localized("chat.upload.draw")
    }

    internal var errorTitle: String {
        return localized("chat.drawing.errorTitle")
    }

    internal var errorMessage: String {
        return localized("chat.drawing.messageTitle")
    }

    internal var fileName: String {
        return localized("chat.drawing.fileName")
    }
}
