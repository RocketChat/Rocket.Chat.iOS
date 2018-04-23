//
//  OAuthViewControllerSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 11/10/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import WebKit

@testable import Rocket_Chat

extension OAuthViewController {
    static func testInstance() -> OAuthViewController {
        let authorizeUrl: URL! = URL(string: "https://authorize.com/test")
        let callbackUrl: URL! = URL(string: "https://callback.com/test?query#fragment")

        return OAuthViewController(authorizeUrl: authorizeUrl, callbackUrl: callbackUrl, success: { _ in }, failure: { })
    }
}

class OAuthViewControllerSpec: XCTestCase {
    func testOauthCredentialsFromUrl() {
        let controller = OAuthViewController.testInstance()
        let callbackUrl: URL! = URL(string: "https://a.com/#%7B%22credentialToken%22:%22token%22,%22credentialSecret%22:%22secret%22%7D")
        let credentials = controller.oauthCredentials(from: callbackUrl)

        XCTAssertEqual(credentials?.token, "token")
        XCTAssertEqual(credentials?.secret, "secret")
    }

    func testOauthCredentialsFromUrlInvalid() {
        let controller = OAuthViewController.testInstance()
        let callbackUrl: URL! = URL(string: "https://a.com/")
        let credentials = controller.oauthCredentials(from: callbackUrl)

        XCTAssertNil(credentials)
    }

    func testIsCallback() {
        let callbackUrlTest: URL! = URL(string: "https://callback.com/test")
        let controller = OAuthViewController.testInstance()
        XCTAssert(controller.isCallback(url: callbackUrlTest))
    }

    func testLoadWebView() {
        let controller = OAuthViewController.testInstance()
        _ = controller.webView
        XCTAssert(controller.view.subviews.contains { view in view as? WKWebView != nil })
    }

    func testLoadActivityIndicator() {
        let controller = OAuthViewController.testInstance()
        _ = controller.activityIndicator
        XCTAssert(controller.view.subviews.contains { view in view as? UIActivityIndicatorView != nil })
    }

    func testWebViewDidStartProvisionalNavigation() {
        let controller = OAuthViewController.testInstance()

        controller.webView(controller.webView, didStartProvisionalNavigation: nil)

        XCTAssertTrue(controller.activityIndicator.isAnimating)
        XCTAssertFalse(controller.activityIndicator.isHidden)
    }

    func testWebViewDidFinishNavigation() {
        let controller = OAuthViewController.testInstance()

        controller.webView(controller.webView, didFinish: nil)

        XCTAssertFalse(controller.activityIndicator.isAnimating)
        XCTAssertTrue(controller.activityIndicator.isHidden)
    }
}
