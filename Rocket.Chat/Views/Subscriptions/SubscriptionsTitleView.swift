//
//  SubscriptionsTitleView.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 9/24/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

class SubscriptionsTitleView: UIView {

    @IBOutlet weak var imageViewServer: UIImageView! {
        didSet {
            imageViewServer.layer.masksToBounds = true
            imageViewServer.layer.cornerRadius = 3

            if let server = DatabaseManager.servers?[DatabaseManager.selectedIndex] {
                if let imageURL = URL(string: server[ServerPersistKeys.serverIconURL] ?? "") {
                    imageViewServer.sd_setImage(with: imageURL)
                }
            }
        }
    }

    @IBOutlet weak var labelUser: UILabel!
    @IBOutlet weak var viewStatus: UIView!

    var user: User? {
        didSet {
            guard let user = user else { return }

            labelUser.text = user.displayName()

            switch user.status {
            case .online:
                viewStatus.backgroundColor = .RCOnline()
                break
            case .busy:
                viewStatus.backgroundColor = .RCBusy()
                break
            case .away:
                viewStatus.backgroundColor = .RCAway()
                break
            case .offline:
                viewStatus.backgroundColor = .RCInvisible()
                break
            }
        }
    }

    override var intrinsicContentSize: CGSize {
        return UILayoutFittingExpandedSize
    }

}
