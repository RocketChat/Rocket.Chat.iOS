//
//  PickerViewDelegate.swift
//  Rocket.Chat
//
//  Created by Vadym Brusko on 10/12/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

class PickerViewDelegate: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {

    typealias SelectHandler = (String) -> Void

    internal var data: [String]
    internal let selectHandler: SelectHandler

    required init(data: [String], selectHandler: @escaping SelectHandler) {
        self.data = data
        self.selectHandler = selectHandler
    }

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectHandler(data[row])
    }

}
