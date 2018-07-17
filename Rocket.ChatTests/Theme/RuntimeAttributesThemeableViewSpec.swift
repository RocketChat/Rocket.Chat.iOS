//
//  RuntimeAttributesThemeableViewSpec.swift
//  Rocket.ChatTests
//
//  Created by Samar Sunkaria on 7/2/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
@testable import Rocket_Chat

class RuntimeAttributesThemeableViewSpec: XCTestCase {
    var view = UIView()

    override func setUp() {
        super.setUp()
        view = UIView()
    }

    func testSetThemeColor() {
        view.setThemeColor("backgroundColor: tintColor")
        view.setThemeColor("tintColor: bodyText")
        view.applyThemeFromRuntimeAttributes()
        // Should not crash

        XCTAssertEqual(view.themeProperties["backgroundColor"], "tintColor", "themeableProperties should contain the key-value pair [backgroundColor: tintColor]")
        XCTAssertEqual(view.themeProperties["tintColor"], "bodyText", "themeableProperties should contain the key-value pair [tintColor: bodyText]")
    }

    func testSetThemeColorWithIncorrectViewKey() {
        view.setThemeColor("not-a-valid-key: tintColor")
        view.applyThemeFromRuntimeAttributes()
        // Should not crash
    }

    func testSetThemeColorWithIncorrectThemeKey() {
        view.setThemeColor("backgroundColor: not-a-valid-key")
        view.applyThemeFromRuntimeAttributes()
        // Should not crash

        guard let theme = view.theme else { return }
        XCTAssertNil(theme.value(forKey: "not-a-valid-key"), "Value for an  undefined should return nil")
    }

    func testSetThemeOverrideColor() {
        view.setThemeColorOverride("backgroundColor: #000000")
        view.setThemeColorOverride("tintColor: #FFFFFF")
        view.applyThemeFromRuntimeAttributes()

        XCTAssertEqual(view.themeOverrideProperties["backgroundColor"], UIColor(hex: "000000"), "themeableProperties should contain the key-value pair [backgroundColor: UIColor(hex: \"000000\")]")
        XCTAssertEqual(view.themeOverrideProperties["tintColor"], UIColor(hex: "FFFFFF"), "themeableProperties should contain the key-value pair [tintColor: UIColor(hex: \"FFFFFF\")]")
    }

    func testSetThemeOverrideColorWithIncorrectViewKey() {
        view.setThemeColorOverride("not-a-valid-key: #000000")
        view.applyThemeFromRuntimeAttributes()
        // Should not crash
    }

    func testApplyThemeFromRuntimeAttributes() {
        view.themeProperties["backgroundColor"] = "tintColor"
        view.themeProperties["tintColor"] = "bodyText"

        let blackColor = UIColor(hex: "000000")
        view.themeOverrideProperties["backgroundColor"] = blackColor
        view.applyThemeFromRuntimeAttributes()

        guard let theme = view.theme else { return }
        XCTAssertEqual(view.backgroundColor, blackColor, "Background color of the view should be #000000")
        XCTAssertEqual(view.tintColor, theme.bodyText, "Tint color of the view should be the same as theme.bodyText")
    }

    func testApplyThemeFromRuntimeAttributesForThemeableProperties() {
        view.themeProperties["backgroundColor"] = "tintColor"
        view.themeProperties["tintColor"] = "bodyText"
        view.applyThemeFromRuntimeAttributes()

        guard let theme = view.theme else { return }
        XCTAssertEqual(view.backgroundColor, theme.tintColor, "Background color of the view should be the same as theme.tintColor")
        XCTAssertEqual(view.tintColor, theme.bodyText, "Tint color of the view should be the same as theme.bodyText")
    }

    func testApplyThemeFromRuntimeAttributesForThemeableOverrideProperties() {
        let blackColor = UIColor(hex: "000000")
        let whiteColor = UIColor(hex: "ffffff")
        view.themeOverrideProperties["backgroundColor"] = blackColor
        view.themeOverrideProperties["tintColor"] = whiteColor
        view.applyThemeFromRuntimeAttributes()

        XCTAssertEqual(view.backgroundColor, blackColor, "Background color of the view should be #000000")
        XCTAssertEqual(view.tintColor, whiteColor, "Tint color of the view should be #FFFFFF")
    }
}
