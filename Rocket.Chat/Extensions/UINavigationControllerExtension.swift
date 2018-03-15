//
//  UINavigationControllerExtension.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 15/03/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
    public func popViewControler(animated: Bool, completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                completion()
            })
            self.popViewController(animated: true)
            CATransaction.commit()
        }
    }
}
