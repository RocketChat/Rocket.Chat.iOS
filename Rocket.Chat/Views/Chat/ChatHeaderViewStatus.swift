//
//  ChatHeaderViewStatus.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 05/12/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

final class ChatHeaderViewStatus: UIView {

    static let defaultHeight = CGFloat(44)

    @IBOutlet weak var labelTitle: UILabel! {
        didSet {
            labelTitle.lineBreakMode = .byTruncatingMiddle
        }
    }

    @IBOutlet weak var buttonRefresh: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    func setTextColor(_ color: UIColor) {
        labelTitle.textColor = color
        activityIndicator.color = color

        let refreshImage = buttonRefresh.image(for: .normal)?.imageWithTint(color)
        buttonRefresh.setImage(refreshImage, for: .normal)
    }

    // MARK: IBAction

    @IBAction func buttonRefreshDidPressed(_ sender: Any) {
        SocketManager.reconnect()
    }

}
