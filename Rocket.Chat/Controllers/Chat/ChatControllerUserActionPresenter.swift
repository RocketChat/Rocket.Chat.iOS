//
//  ChatControllerUserActionPresenter.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 5/16/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

extension ChatViewController {
    func presentActionSheetForUser(_ user: User, source: (view: UIView?, rect: CGRect?)?) {
        presentActionSheetForUser(user, subscription: subscription, source: source)
    }
}
