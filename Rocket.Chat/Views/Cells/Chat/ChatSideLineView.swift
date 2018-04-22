//
//  ChatSideLineView.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 4/22/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class ChatSideLineView: UIView {
    override func awakeFromNib() {
        layer.cornerRadius = bounds.width / 2
        layer.masksToBounds = true
    }
}
