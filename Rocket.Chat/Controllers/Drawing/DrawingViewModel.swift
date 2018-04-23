//
//  DrawingViewModel.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 13.02.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

struct DrawingViewModel {

    internal static let defaultBrushColor: UIColor = .black
    internal static let defaultBrushWidth: CGFloat = 10.0
    internal static let defaultBrushOpacity: CGFloat = 1.0

    internal let title = localized("chat.upload.draw")
    internal var errorTitle = localized("chat.drawing.errorTitle")
    internal var errorMessage = localized("chat.drawing.messageTitle")
    internal var fileName = localized("chat.drawing.fileName")

}
