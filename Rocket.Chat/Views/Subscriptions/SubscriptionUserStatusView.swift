//
//  SubscriptionUserStatusView.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 13/02/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

protocol SubscriptionUserStatusViewProtocol: class {
    func userDidPressedOption()
}

final class SubscriptionUserStatusView: UIView, UserManagerInjected, AuthManagerInjected {

    var injectionContainer: InjectionContainer!
    weak var delegate: SubscriptionUserStatusViewProtocol?
    weak var parentController: UIViewController?

    @IBOutlet weak var buttonOnline: UIButton!
    @IBOutlet weak var labelOnline: UILabel! {
        didSet {
            labelOnline.text = localized("user_menu.online")
        }
    }

    @IBOutlet weak var buttonAway: UIView!
    @IBOutlet weak var labelAway: UILabel! {
        didSet {
            labelAway.text = localized("user_menu.away")
        }
    }

    @IBOutlet weak var buttonBusy: UIView!
    @IBOutlet weak var labelBusy: UILabel! {
        didSet {
            labelBusy.text = localized("user_menu.busy")
        }
    }

    @IBOutlet weak var buttonInvisible: UIView!
    @IBOutlet weak var labelInvisible: UILabel! {
        didSet {
            labelInvisible.text = localized("user_menu.invisible")
        }
    }

    @IBOutlet weak var buttonSettings: UIView!
    @IBOutlet weak var labelSettings: UILabel! {
        didSet {
            labelSettings.text = localized("user_menu.settings")
        }
    }

    @IBOutlet weak var imageViewSettings: UIImageView! {
        didSet {
            imageViewSettings.image = imageViewSettings.image?.imageWithTint(.RCLightBlue())
        }
    }

    @IBOutlet weak var buttonLogout: UIView!
    @IBOutlet weak var labelLogout: UILabel! {
        didSet {
            labelLogout.text = localized("user_menu.logout")
        }
    }

    @IBOutlet weak var imageViewLogout: UIImageView! {
        didSet {
            imageViewLogout.image = imageViewLogout.image?.imageWithTint(.RCLightBlue())
        }
    }

    // MARK: IBAction

    @IBAction func buttonOnlineDidPressed(_ sender: Any) {
        userManager.setUserStatus(status: .online) { [weak self] (_) in
            self?.delegate?.userDidPressedOption()
        }
    }

    @IBAction func buttonAwayDidPressed(_ sender: Any) {
        userManager.setUserStatus(status: .away) { [weak self] (_) in
            self?.delegate?.userDidPressedOption()
        }
    }

    @IBAction func buttonBusyDidPressed(_ sender: Any) {
        userManager.setUserStatus(status: .busy) { [weak self] (_) in
            self?.delegate?.userDidPressedOption()
        }
    }

    @IBAction func buttonInvisibleDidPressed(_ sender: Any) {
        userManager.setUserStatus(status: .offline) { [weak self] (_) in
            self?.delegate?.userDidPressedOption()
        }
    }

    @IBAction func buttonSettingsDidPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Settings", bundle: Bundle.main)

        if let controller = storyboard.instantiateInitialViewController() {
            controller.modalPresentationStyle = .formSheet
            parentController?.present(controller, animated: true, completion: nil)
        }

        self.delegate?.userDidPressedOption()
    }

    @IBAction func buttonLogoutDidPressed(_ sender: Any) {
        // RKS NOTE: I know that this isn't the best place, but we need to fix
        // this crash ASAP. In the future we may have a centered place for all
        // database notifications.
        ChatViewController.sharedInstance()?.messagesToken?.stop()
        SubscriptionsViewController.sharedInstance()?.usersToken?.stop()
        SubscriptionsViewController.sharedInstance()?.subscriptionsToken?.stop()

        authManager.logout {
            let storyboardChat = UIStoryboard(name: "Main", bundle: Bundle.main)
            let controller = storyboardChat.instantiateInitialViewController()
            let application = UIApplication.shared

            if let window = application.keyWindow {
                window.rootViewController = controller
                window.makeKeyAndVisible()
            }
        }
    }

}
