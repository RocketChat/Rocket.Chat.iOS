//
//  InfoRequestHandlerSpec.swift
//  Rocket.ChatTests
//
//  Created by Rafael Kellermann Streit on 11/16/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest

@testable import Rocket_Chat

class InfoRequestHandlerFakeDelegate: InfoRequestHandlerDelegate {

    var isServerValid = false
    var isURLValid = true
    var newServerURL: String?

    var viewControllerToPresentAlerts: UIViewController? {
        return UIViewController()
    }

    func urlNotValid() {
        isURLValid = false
    }

    func serverChangedURL(_ newURL: String?) {
        newServerURL = newURL
    }

    func serverIsValid() {
        isServerValid = true
    }

}

class InfoRequestHandlerSpec: XCTestCase {

    let controller = InfoRequestHandlerFakeDelegate()
    let instance = InfoRequestHandler()

    override func setUp() {
        instance.delegate = controller
        instance.url = URL(string: "https://open.rocket.chat")
    }

    func testViewControllerDelegateMethod() {
        XCTAssertNotNil(instance.delegate?.viewControllerToPresentAlerts, "view controller won't be nil")
    }

    func testServerIsValidDelegateMethod() {
        instance.delegate?.serverIsValid()
        XCTAssertTrue(controller.isServerValid, "server is valid after delegate being called")
    }

    func testUrlNotValidDelegateMethod() {
        instance.delegate?.urlNotValid()
        XCTAssertFalse(controller.isURLValid, "url is invalid after delegate being called")
    }

    func testServerChangedUrlNotEmptyDelegateMethod() {
        instance.delegate?.serverChangedURL("foo")
        XCTAssertEqual(controller.newServerURL, "foo", "controller now has the new URL")
    }

    func testServerChangedUrlEmptyDelegateMethod() {
        instance.delegate?.serverChangedURL(nil)
        XCTAssertNil(controller.newServerURL, "newURL can also be nil")
    }

}
