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
        guard let userId = user.identifier else {
            return
        }


        let controller = UIAlertController(title: user.displayName(), message: nil, preferredStyle: .actionSheet)
        controller.popoverPresentationController?.sourceView = source?.view
        controller.popoverPresentationController?.sourceRect = source?.rect ?? source?.view?.frame ?? .zero

        // Conversation (Open DM)

        controller.addAction(UIAlertAction(title: localized("user_action_sheet.conversation"), style: .default, handler: { [weak self] _ in
            guard let username = user.username else { return }

            AppManager.openDirectMessage(username: username) {
                controller.dismiss(animated: true, completion: nil)
                self?.close(animated: true)
            }
        }))

        // Remove User (Kick)
        let api = API.current()

        if let subscription = subscription {
            if AuthManager.currentUser()?.hasPermission(.removeUser, subscription: subscription) == true {
                controller.addAction(UIAlertAction(title: localized("user_action_sheet.remove"), style: .destructive, handler: { [weak self] _ in
                    self?.alertYesNo(
                        title: localized("user_action_sheet.remove_confirm.title"),
                        message: localized("user_action_sheet.remove_confirm.message"),
                        handler: { yes in
                            if yes {
                                api?.fetch(
                                    RoomKickRequest(
                                        roomId: subscription.rid,
                                        roomType: subscription.type,
                                        userId: userId
                                    )
                                ) { response in
                                    switch response {
                                    case .resource(let resource):
                                        if let error = resource.error {
                                            return Alert(
                                                title: "Error",
                                                message: error
                                            ).present()
                                        }
                                    case .error(let error):
                                        print(error)
                                    }
                                }
                            }
                    })
                }))
            }
        }

        controller.addAction(UIAlertAction(title: localized("global.cancel"), style: .cancel))

        present(controller, animated: true, completion: nil)
    }
}
