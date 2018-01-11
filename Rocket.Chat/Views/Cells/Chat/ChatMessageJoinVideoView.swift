//
//  ChatMessageJoinVideoView.swift
//  RocketChat
//
//  Created by Luís Machado on 18/12/2017.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

protocol ChatMessageJoinVideoViewProtocol: class {
    func openVideoChat()
}

final class ChatMessageJoinVideoView: UIView {
    static let defaultHeight = CGFloat(50)
    weak var delegate: ChatMessageJoinVideoViewProtocol?
    var roomUrl: String!

    @IBOutlet weak var joinChatButton: UIButton! {
        didSet {
            joinChatButton.layer.cornerRadius = 5
            joinChatButton.setTitle(localized("chat.videochat.click_to_join"), for: .normal)
            if let image = UIImage(named: "facetime") {
                joinChatButton.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
            }
            joinChatButton.tintColor = .green
        }
    }

    @IBAction func joinChatPressed(_ sender: Any) {
        delegate?.openVideoChat()
    }
}
