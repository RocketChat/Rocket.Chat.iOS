//
//  UserActionSheetPresenter.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 4/26/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

protocol UserActionSheetPresenter: Closeable {
    func presentActionSheetForUser(_ user: User, subscription: Subscription?, source: (view: UIView?, rect: CGRect?)?)
}

extension UserActionSheetPresenter where Self: UIViewController {
    func presentActionSheetForUser(_ user: User, subscription: Subscription? = nil, source: (view: UIView?, rect: CGRect?)? = nil) {
        let controller = UIAlertController(title: user.displayName(), message: nil, preferredStyle: .actionSheet)
        controller.popoverPresentationController?.sourceView = source?.view
        controller.popoverPresentationController?.sourceRect = source?.rect ?? source?.view?.frame ?? .zero

        controller.addAction(UIAlertAction(title: localized("user_action_sheet.conversation"), style: .default, handler: { [weak self] _ in
            guard let username = user.username else { return }

            AppManager.openDirectMessage(username: username) {
                controller.dismiss(animated: true, completion: nil)
                self?.close(animated: true)
            }
        }))

        if let subscription = subscription {
            if AuthManager.currentUser()?.hasPermission(.removeUser, subscription: subscription) == true {
                controller.addAction(UIAlertAction(title: localized("user_action_sheet.remove"), style: .destructive))
            }
        }

        controller.addAction(UIAlertAction(title: localized("global.cancel"), style: .cancel))

        present(controller, animated: true, completion: nil)
    }
}
