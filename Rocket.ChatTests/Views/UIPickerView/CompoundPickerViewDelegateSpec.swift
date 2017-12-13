//
//  CompoundPickerViewDelegateSpec.swift
//  Rocket.ChatTests
//
//  Created by Rafael Kellermann Streit on 10/27/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift

@testable import Rocket_Chat

class CompoundPickerViewDelegateSpec: XCTestCase {

    func testInitialization() {
        let instance = CompoundPickerViewDelegate()
        XCTAssertNotNil(instance, "instance is not nil")
        XCTAssertNotNil(instance.pickerHandlers, "pickerHandlers is not nil")
        XCTAssertEqual(instance.pickerHandlers.count, 0, "pickerHandlers is empty")
    }

    func testAppend() {
        let instance = CompoundPickerViewDelegate()

        let pickerViewDelegate = PickerViewDelegate(data: []) { _ in
            // do nothing
        }

        instance.append(pickerViewDelegate)
        XCTAssertEqual(instance.pickerHandlers.count, 1, "pickerHandlers has one element")
    }

}
