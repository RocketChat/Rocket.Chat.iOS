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

    private let source: [String]
    private let selectHandler: SelectHandler

    init(source: [String], selectHandler: @escaping SelectHandler) {
        self.source = source
        self.selectHandler = selectHandler
    }

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return source.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return source[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectHandler(source[row])
    }
}
