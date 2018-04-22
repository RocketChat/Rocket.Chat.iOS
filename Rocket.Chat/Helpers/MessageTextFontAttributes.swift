//
//  MessageTextFontAttributes.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 01/03/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

struct MessageTextFontAttributes {

    static let defaultFontSize = CGFloat(16)

    static let defaultFontColor = #colorLiteral(red: 0.1241737381, green: 0.1242020801, blue: 0.1241700128, alpha: 1)
    static let systemFontColor = UIColor.lightGray
    static let failedFontColor = UIColor.lightGray

    static let defaultFont = UIFont.systemFont(ofSize: defaultFontSize)
    static let italicFont = UIFont.italicSystemFont(ofSize: defaultFontSize)
    static let boldFont = UIFont.boldSystemFont(ofSize: defaultFontSize)

}
