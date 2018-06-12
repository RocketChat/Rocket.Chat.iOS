//
//  WindowManager.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 11/17/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

enum Storyboard {
    case auth(serverUrl: String, credentials: DeepLinkCredentials?)
    case chat
    case preferences
    case subscriptions

    var name: String {
        switch self {
        case .auth: return "Auth"
        case .chat: return "Chat"
        case .preferences: return "Preferences"
        case .subscriptions: return "Subscriptions"
        }
    }

    func instantiate() -> UIStoryboard {
        return UIStoryboard(name: name, bundle: Bundle.main)
    }

    func initialViewController() -> UIViewController? {
        let storyboard = instantiate()
        let controller = storyboard.instantiateInitialViewController()

        // preload view
        _ = controller?.view

        switch self {
        case let .auth(serverUrl, credentials):
            let navigationController = (controller as? UINavigationController)
            let controller = navigationController?.topViewController as? ConnectServerViewController
            _ = controller?.view
            controller?.textFieldServerURL.text = serverUrl

            if serverUrl.count > 0 {
                controller?.connect()
                controller?.deepLinkCredentials = credentials
            }
        default:
            break
        }

        return controller
    }

    func instantiate(viewController: String) -> UIViewController? {
        let storyboard = instantiate()
        return storyboard.instantiateViewController(withIdentifier: viewController)
    }
}

final class WindowManager {

    /**
        This method will transform the keyWindow.rootViewController
        into the initial view controller of storyboard with name param.

        - parameter name: The name of the Storyboard to be instantiated.
        - parameter transitionType: The transition to open new view controller.
     */
    static func open(_ storyboard: Storyboard, transitionType: String = kCATransitionFade) {
        let controller = storyboard.initialViewController()
        let application = UIApplication.shared

        if let window = application.windows.first, let controller = controller {
            let transition = CATransition()
            transition.type = transitionType
            window.set(rootViewController: controller, withTransition: transition)
        }
    }

}
