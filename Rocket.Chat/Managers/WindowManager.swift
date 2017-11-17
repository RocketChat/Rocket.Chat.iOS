//
//  WindowManager.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 11/17/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

enum Storyboard: String {
    case auth = "Auth"
    case chat = "Chat"
    case main = "Main"
}

class WindowManager {

    /**
        This method will transform the keyWindow.rootViewController
        into the initial view controller of storyboar with name param.

        - parameter name: The name of the Storyboard to be instantiated.
        - parameter transitionType: The transition to open new view controller.
     */
    static func open(_ name: Storyboard, transitionType: String = kCATransitionFade) {
        let storyboardChat = UIStoryboard(name: name.rawValue, bundle: Bundle.main)
        let controller = storyboardChat.instantiateInitialViewController()
        let application = UIApplication.shared

        if let window = application.keyWindow, let controller = controller {
            let transition = CATransition()
            transition.type = transitionType
            window.set(rootViewController: controller, withTransition: transition)
        }
    }

}
