//
//  VOTextField.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 12/5/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

class VOTextField: UITextField {
    override var accessibilityLabel: String? {
        get { return localizedAccessibilityLabel }
        set { }
    }

    override var accessibilityHint: String? {
        get { return localizedAccessibilityHint }
        set { }
    }
}
