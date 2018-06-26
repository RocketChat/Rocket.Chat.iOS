//
//  UIViewControllerPresent.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 6/26/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

extension UIViewController {
    func pushOrPresent(_ vc: UIViewController) {
        if UIDevice.current.userInterfaceIdiom == .phone, let navigationController = navigationController {
            navigationController.pushViewController(vc, animated: true)
        } else {
            self.present(vc, animated: true)
        }
    }
}
