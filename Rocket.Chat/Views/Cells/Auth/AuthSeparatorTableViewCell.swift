//
//  AuthSeparatorTableViewCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 05/06/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

final class AuthSeparatorTableViewCell: UITableViewCell {

    static let rowHeight: CGFloat = 31.0

}

// MARK: Disable Theming

extension AuthSeparatorTableViewCell {
    override func applyTheme() { }
}
