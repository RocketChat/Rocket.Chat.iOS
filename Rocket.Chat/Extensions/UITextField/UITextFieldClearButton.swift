//
//  UITextFieldClearButton.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 6/14/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

extension UITextField {
    var clearButton: UIButton? {
        return value(forKey: "_clearButton") as? UIButton
    }
}
