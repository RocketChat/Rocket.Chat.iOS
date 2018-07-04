//
//  UIViewControllerPushOrPresent.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 6/26/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

extension UIViewController {
    func pushOrPresent(_ controller: UIViewController, style: UIModalPresentationStyle = .formSheet, source: (view: UIView?, rect: CGRect?)? = nil) {
        if UIDevice.current.userInterfaceIdiom == .phone, let navigationController = navigationController {
            navigationController.pushViewController(controller, animated: true)
        } else {
            controller.modalPresentationStyle = .popover
            controller.popoverPresentationController?.sourceRect = source?.rect ?? source?.view?.frame ?? .zero
            controller.popoverPresentationController?.sourceView = source?.view
            self.present(controller, animated: true)
        }
    }
}
