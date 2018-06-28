//
//  UIViewControllerPushOrPresent.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 6/26/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

extension UIViewController {
    func pushOrPresent(_ controller: UIViewController) {
        if UIDevice.current.userInterfaceIdiom == .phone, let navigationController = navigationController {
            navigationController.pushViewController(controller, animated: true)
        } else {
            self.present(controller, animated: true)
        }
    }
}
