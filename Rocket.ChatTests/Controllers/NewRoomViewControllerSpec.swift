//
//  NewRoomViewControllerSpec.swift
//  Rocket.ChatTests
//
//  Created by Bruno Macabeus Aquino on 15/10/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift
@testable import Rocket_Chat

class NewRoomViewControllerSpec: XCTestCase {
    func testDefaultsValues() {
        let controller = NewRoomViewController()
        let setValues = controller.setValues
        let tableViewData = controller.tableViewData

        let countTotalCells = tableViewData.reduce(0) { $0 + $1.cells.count }
        XCTAssertEqual(setValues.count, countTotalCells, "Number of defaults values is correct")

        tableViewData.forEach { group in
            group.cells.forEach {
                guard let currentValue = setValues[$0.key] else {
                    return XCTFail("Default value of \($0.key) was not set")
                }

                XCTAssertTrue(type(of: currentValue) == type(of: $0.defaultValue), "Default value of \($0.key) was set with same type")
            }
        }
    }
}
