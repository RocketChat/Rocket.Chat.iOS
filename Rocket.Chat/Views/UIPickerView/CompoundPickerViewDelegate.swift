//
//  CompoundPickerViewDelegate.swift
//  Rocket.Chat
//
//  Created by Vadym Brusko on 10/12/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

class CompoundPickerViewDelegate {
	internal var pickerHandlers: [PickerViewDelegate] = [PickerViewDelegate]()

    func append(_ handler: PickerViewDelegate) {
        pickerHandlers.append(handler)
    }
}
