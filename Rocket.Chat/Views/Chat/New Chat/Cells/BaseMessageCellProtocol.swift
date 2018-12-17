//
//  BaseMessageCellProtocol.swift
//  Rocket.Chat
//
//  Created by Rafael Streit on 08/11/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

protocol BaseMessageCellProtocol {
    var delegate: ChatMessageCellProtocol? { get set }
}
