//
//  ThemeManagerSpec.swift
//  Rocket.ChatTests
//
//  Created by Samar Sunkaria on 5/2/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
@testable import Rocket_Chat

class ThemeManagerSpec: XCTestCase {

    class MockObserver: Themeable {
        var themeApplied = false
        func applyTheme() {
            themeApplied = true
        }
    }

    var mockObserver = MockObserver()

    override func setUp() {
        super.setUp()
        mockObserver = MockObserver()
    }

    override func tearDown() {
        super.tearDown()
        ThemeManager.observers.removeAll()
        ThemeManager.theme = .light
        UserDefaults.standard.set(nil, forKey: ThemeManager.userDefaultsKey)
    }

    func testAddingObserver() {
        ThemeManager.addObserver(mockObserver)
        XCTAssert(ThemeManager.observers.contains(where: {
            guard let value = $0.value else { return false }
            return value === mockObserver
        }), "Theme manager should have a reference to the observer")
    }

    func testRemovingObserver() {
        ThemeManager.addObserver(mockObserver)
        mockObserver = MockObserver() // Should release the old reference
        XCTAssert(ThemeManager.observers.compactMap({ $0.value }).isEmpty, "Theme manager should not retain a reference to the observer")
    }

    func testApplyThemeCalled() {
        ThemeManager.addObserver(mockObserver)
        XCTAssert(mockObserver.themeApplied, "applyTheme should be called")
        mockObserver.themeApplied = false
        ThemeManager.theme = .dark
        XCTAssert(mockObserver.themeApplied, "applyTheme should be called")
    }

    func testStoringThemeInUserDefaults() {
        let theme = Theme.dark
        ThemeManager.theme = theme
        let themeName = UserDefaults.standard.string(forKey: ThemeManager.userDefaultsKey)
        XCTAssertNotNil(themeName, "The theme should be stored in the User Deafults")
        XCTAssertEqual(ThemeManager.themes.first(where: { $0.theme == theme })?.title, themeName, "The theme stored in user defaults should be the same as the theme assigned to the theme manager.")
    }

    func testRetrievingThemeFromUserDefaultsWhenKeyIsNotStored() {
        if UserDefaults.standard.string(forKey: ThemeManager.userDefaultsKey) == nil {
            XCTAssertEqual(ThemeManager.theme, Theme.light, "The light theme should be the default theme in case value is not stored in user defaults")
            return
        }
    }
}
