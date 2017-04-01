//
//  UIViewExtentions.swift
//  Rocket.Chat
//
//  Created by Rafael Machado on 12/10/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import UIKit

extension UIView {

    static var nib: UINib {
        return UINib(nibName: "\(self)", bundle: nil)
    }

    static func instantiateFromNib() -> Self? {
        func instanceFromNib<T: UIView>() -> T? {
            return nib.instantiate() as? T
        }

        return instanceFromNib()
    }

}
