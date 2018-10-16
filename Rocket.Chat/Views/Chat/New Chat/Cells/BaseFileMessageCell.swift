//
//  BaseFileMessageCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 16/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController

class BaseFileMessageCell: MessageHeaderCell {
    weak var delegate: ChatMessageCellProtocol?
}
