//
//  RCPickerView.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 16.07.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

// Subclassing PickerView to prevent it being themed
final class RCPickerView: UIPickerView {
    override var theme: Theme? {
        return nil
    }
}
