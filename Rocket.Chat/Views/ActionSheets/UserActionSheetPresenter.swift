//
//  UserActionSheetPresenter.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 4/26/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

enum UserAction {
    case remove
    case conversation
    case none
}

protocol UserActionSheetPresenter: Closeable {
    func presentActionSheetForUser(_ user: User, subscription: Subscription?, source: (view: UIView?, rect: CGRect?)?, completion: ((UserAction) -> Void)?)
}

extension UserActionSheetPresenter where Self: UIViewController {
    func presentActionSheetForUser(_ user: User, subscription: Subscription? = nil, source: (view: UIView?, rect: CGRect?)? = nil, completion: ((UserAction) -> Void)? = nil) {
        guard let userId = user.identifier, AuthManager.currentUser()?.identifier != userId else {
            return
        }

        let controller = UIAlertController(title: user.displayName(), message: nil, preferredStyle: .actionSheet)
        controller.popoverPresentationController?.sourceView = source?.view
        controller.popoverPresentationController?.sourceRect = source?.rect ?? source?.view?.frame ?? .zero

        // Conversation (Open DM)

        controller.addAction(UIAlertAction(title: localized("user_action_sheet.conversation"), style: .default, handler: { [weak self] _ in
            guard let username = user.username else { return }

            self?.close(animated: true)

            AppManager.openDirectMessage(username: username) {
                completion?(.conversation)
                controller.dismiss(animated: true, completion: nil)
            }
        }))

        // Remove User (Kick)
        let api = API.current()

        if let subscription = subscription {
            if AuthManager.currentUser()?.hasPermission(.removeUser, subscription: subscription) == true {
                controller.addAction(UIAlertAction(title: localized("user_action_sheet.remove"), style: .destructive, handler: { [weak self] _ in
                    let message = String(format: localized("user_action_sheet.remove_confirm.message"), user.username ?? "")
                    self?.alertYesNo(title: localized("user_action_sheet.remove_confirm.title"), message: message) { yes in
                        guard yes else { completion?(.none); return }

                        api?.fetch(RoomKickRequest(roomId: subscription.rid, roomType: subscription.type, userId: userId)) { response in
                            switch response {
                            case .resource(let resource):
                                if let error = resource.error {
                                    completion?(.none)
                                    return Alert(title: localized("global.error"), message: error).present()
                                } else {
                                    completion?(.remove)
                                }
                            case .error:
                                completion?(.none)
                            }
                        }
                    }
                }))
            }
        }

        controller.addAction(UIAlertAction(title: localized("global.cancel"), style: .cancel))

        present(controller, animated: true, completion: nil)
    }
}
