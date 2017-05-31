//
//  UIViewExtensions.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 5/31/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

extension UIView {

    static var nib: UINib {
        return UINib(nibName: "\(self)", bundle: RocketChat.resourceBundle)
    }

    static func instantiateFromNib() -> Self? {
        func instanceFromNib<T: UIView>() -> T? {
            return nib.instantiate() as? T
        }

        return instanceFromNib()
    }
    
}
