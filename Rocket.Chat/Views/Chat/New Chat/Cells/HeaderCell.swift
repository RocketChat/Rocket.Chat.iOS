//
//  HeaderCell.swift
//  Rocket.Chat
//
//  Created by Rafael Streit on 19/11/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController

final class HeaderCell: UICollectionViewCell, ChatCell, SizingCell {
    static let identifier = String(describing: HeaderCell.self)

    static let sizingCell: UICollectionViewCell & ChatCell = {
        guard let cell = HeaderCell.instantiateFromNib() else {
            return HeaderCell()
        }

        return cell
    }()

    var messageWidth: CGFloat = 0
    var viewModel: AnyChatItem?

    func configure() {
        
    }

}
