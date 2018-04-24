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

    var controller = InfoRequestHandlerFakeDelegate()
    let instance = InfoRequestHandler()

    override func setUp() {
        controller = InfoRequestHandlerFakeDelegate()

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

    func testValidateServerResponseSuccess() {
        let result = InfoResource(raw: ["info": ["version": "0.54.0"]])
        instance.validateServerResponse(result: result)
        XCTAssertTrue(controller.isServerValid, "server is valid after validation for valid result")
        XCTAssertTrue(controller.isURLValid, "url is valid after validation for valid result")
    }

    func testValidateServerResponseError() {
        let result = InfoResource(raw: nil)
        instance.validateServerResponse(result: result)
        XCTAssertFalse(controller.isServerValid, "server is invalid after validation for emtpy result")
        XCTAssertFalse(controller.isURLValid, "url is invalid after validation for empty result")
    }

    func testValidateServerResponseInvalid() {
        let result = InfoResource(raw: ["foo": "bar"])
        instance.validateServerResponse(result: result)
        XCTAssertFalse(controller.isServerValid, "server is invalid after validation for invalid result")
        XCTAssertFalse(controller.isURLValid, "url is invalid after validation for invalid result")
    }

    func testHandleRedirectInfoResultError() {
        guard let newURL = URL(string: "https://foo.com") else {
            return XCTFail("newURL must be valid")
        }

        let result = InfoResource(raw: nil)
        instance.handleRedirectInfoResult(result, for: newURL)
        XCTAssertFalse(controller.isURLValid, "url is not valid")
    }

    func testHandleRedirectInfoResultSuccess() {
        guard let newURL = URL(string: "https://foo.com") else {
            return XCTFail("newURL must be valid")
        }

        let result = InfoResource(raw: ["version": "0.54.0"])
        instance.handleRedirectInfoResult(result, for: newURL)
        XCTAssertTrue(controller.isURLValid, "url is valid")
    }

}
