//
//  DrawingBrushColorViewModel.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 12.02.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

final class DrawingBrushColorViewModel {
    internal let cellIdentifier = "DrawingBrushColorCell"

    internal var selectedColorLabel: String {
        return localized("chat.drawing.settings.color.selected")
    }

    internal var othersLabel: String {
        return localized("chat.drawing.settings.color.others")
    }

    internal let availableColors: [UIColor] = [
        .black,
        .darkGray,
        .lightGray,
        .gray,
        .red,
        .green,
        .blue,
        .cyan,
        .yellow,
        .magenta,
        .orange,
        .purple,
        .brown,

        // custom
        UIColor(hex: "#FFC0CB"),
        UIColor(hex: "#008080"),
        UIColor(hex: "#FFE4E1"),
        UIColor(hex: "#FFD700"),
        UIColor(hex: "#D3FFCE"),
        UIColor(hex: "#FF7373"),
        UIColor(hex: "#40E0D0"),
        UIColor(hex: "#E6E6FA"),
        UIColor(hex: "#B0E0E6"),
        UIColor(hex: "#C6E2FF"),
        UIColor(hex: "#003366"),
        UIColor(hex: "#800080"),
        UIColor(hex: "#347CA0"),
        UIColor(hex: "#C7CA24"),
        UIColor(hex: "#FD91A0"),
        UIColor(hex: "#F9AF91")
    ]
}
