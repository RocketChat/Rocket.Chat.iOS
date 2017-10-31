//
//  PickerViewDelegateSpec.swift
//  Rocket.ChatTests
//
//  Created by Rafael Kellermann Streit on 10/27/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift

@testable import Rocket_Chat

class PickerViewDelegateSpec: XCTestCase {

    func testInitialization() {
        let instance = PickerViewDelegate(data: ["foo"]) { (_) in
            // do nothing
        }

        XCTAssertNotNil(instance, "instance is not nil")
        XCTAssertNotNil(instance.data, "data is not nil")
        XCTAssertNotNil(instance.selectHandler, "handler is not nil")
        XCTAssertEqual(instance.data.count, 1, "data is not empty")
    }

    func testNumberOfComponents() {
        let instance = PickerViewDelegate(data: ["foo"]) { (_) in
            // do nothing
        }

        let pickerView = UIPickerView()
        pickerView.delegate = instance
        pickerView.dataSource = instance

        XCTAssertEqual(instance.numberOfComponents(in: pickerView), 1, "number of components will match")
    }

    func testNumberOfRows() {
        let instance = PickerViewDelegate(data: ["foo"]) { (_) in
            // do nothing
        }

        let pickerView = UIPickerView()
        pickerView.delegate = instance
        pickerView.dataSource = instance

        XCTAssertEqual(pickerView.numberOfRows(inComponent: 0), 1, "number of rows will match")
    }

    func testTitleForRow() {
        let instance = PickerViewDelegate(data: ["foo"]) { (_) in
            // do nothing
        }

        let pickerView = UIPickerView()
        pickerView.delegate = instance
        pickerView.dataSource = instance

        XCTAssertEqual(instance.pickerView(pickerView, titleForRow: 0, forComponent: 0), "foo", "title will match")
    }

    func testTitleForHandler() {
        var handlerWasCalled = false
        let instance = PickerViewDelegate(data: ["foo"]) { (_) in
            handlerWasCalled = true
        }

        let pickerView = UIPickerView()
        pickerView.delegate = instance
        pickerView.dataSource = instance

        instance.pickerView(pickerView, didSelectRow: 0, inComponent: 0)
        XCTAssertTrue(handlerWasCalled, "handler was called")
    }

}
