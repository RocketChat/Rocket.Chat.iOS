//
//  ChatControllerTitleViewProtocol.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 9/24/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

extension ChatViewController: ChatTitleViewProtocol {

    func titleViewButtonChannelDidPressed() {
        performSegue(withIdentifier: "Channel Actions", sender: nil)
    }

    func titleViewButtonMoreDidPressed() {
        performSegue(withIdentifier: "Channel Actions", sender: nil)
    }

}
