//
//  UserActionSheetPresenter.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 4/26/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import RealmSwift

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

        // Information (Open User Details)

        let openUserDetails = { [weak self] in
            let detailController = UserDetailViewController.fromStoryboard().withModel(.forUser(user))
            detailController.modalPresentationStyle = .formSheet
            self?.pushOrPresent(detailController, source: source)

            API.current()?.client(UsersClient.self).fetchUser(user) { [weak detailController] response in
                if case let .resource(resource) = response, let user = resource.user {
                    detailController?.model = .forUser(user)
                }
            }
        }

        controller.addAction(UIAlertAction(title: localized("user_action_sheet.info"), style: .default, handler: { _ in openUserDetails() }))

        // Remove User (Kick)
        let api = API.current()

        if let subscription = subscription {
            if AuthManager.currentUser()?.hasPermission(.removeUser, subscription: subscription) == true {
                controller.addAction(UIAlertAction(title: localized("user_action_sheet.remove"), style: .destructive, handler: { [weak self] _ in
                    let message = String(format: localized("user_action_sheet.remove_confirm.message"), user.username ?? "")
                    self?.alertYesNo(title: localized("user_action_sheet.remove_confirm.title"), message: message, yesStyle: .destructive) { yes in
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

        if controller.actions.count == 1 {
            openUserDetails()
        } else {
            controller.addAction(UIAlertAction(title: localized("global.cancel"), style: .cancel))
            present(controller, animated: true, completion: nil)
        }
    }
}
