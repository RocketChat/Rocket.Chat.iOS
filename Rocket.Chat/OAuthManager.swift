//
//  OAuthManager.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 10/23/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import OAuthSwift
import UIKit
import SwiftyJSON

class OAuthCredentials {
    let token: String
    let secret: String

    init?(json: JSON) {
        guard
            let token = json["credentialToken"].string,
            let secret = json["credentialSecret"].string
        else {
            return nil
        }

        self.token = token
        self.secret = secret
    }
}

class OAuthManager {
    private static var oauthSwift: OAuth2Swift?

    static func callbackURL(for loginService: LoginService, server: URL) -> URL? {
        guard
            let host = server.host,
            let service = loginService.service
        else {
            return nil
        }

        return URL(string: "https://\(host)/_oauth/\(service)")
    }

    static func state() -> String? {
        return "{\"loginStyle\":\"popup\",\"credentialToken\":\"\(String.random(40))\",\"isCordova\":true}".base64Encoded()
    }

    static func oauthSwift(for loginService: LoginService) -> OAuth2Swift? {
        guard
            let authorizeUrl = loginService.authorizeUrl,
            let accessTokenUrl = loginService.accessTokenUrl,
            let clientId = loginService.clientId
            else {
                return nil
        }

        return OAuth2Swift(
            consumerKey: clientId,
            consumerSecret: "",
            authorizeUrl: authorizeUrl,
            accessTokenUrl: accessTokenUrl,
            responseType: "token"
        )
    }

    static func credentialsForUrlFragment(_ fragment: String) -> OAuthCredentials? {
        guard let normalizedFragment = fragment.removingPercentEncoding else {
            return nil
        }

        let fragmentJSON = JSON(parseJSON: normalizedFragment)
        return OAuthCredentials(json: fragmentJSON)
    }

    static func authorize(loginService: LoginService, at server: URL, viewController: UIViewController, success: @escaping (OAuthCredentials) -> Void, failure: @escaping () -> Void) {
        guard
            let callbackURL = callbackURL(for: loginService, server: server),
            let oauthSwift = oauthSwift(for: loginService),
            let authorizeURL = loginService.authorizeUrl,
            let scope = loginService.scope,
            let state = state()
        else {
            failure()
            return
        }

        self.oauthSwift = oauthSwift

        let handler = WebViewController(authorizeURL: URL(string: authorizeURL))
        oauthSwift.removeCallbackNotificationObserver()
        viewController.navigationController?.pushViewController(handler, animated: true)
        handler.didNavigate = { url in
            guard
                let url = url,
                url.host == callbackURL.host &&
                url.path == callbackURL.path,
                let fragment = url.fragment
            else {
                return false
            }

            guard let credentials = credentialsForUrlFragment(fragment) else {
                failure()
                return true
            }

            success(credentials)
            return true
        }

        oauthSwift.authorizeURLHandler = handler
        oauthSwift.authorize(withCallbackURL: callbackURL, scope: scope,
                             state: state, success: { _, _, _  in }, failure: { _ in failure() })
    }
}
