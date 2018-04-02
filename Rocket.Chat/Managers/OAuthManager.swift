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
    let secret: String?

    init(token: String, secret: String?) {
        self.token = token
        self.secret = secret
    }

    init?(json: JSON) {
        guard let token = json["credentialToken"].string else { return nil }

        self.token = token
        self.secret = json["credentialSecret"].string
    }
}

class OAuthManager {
    private static var oauthSwift: OAuthSwift?
    private static var oauth1Swift: OAuth1Swift?

    @discardableResult
    static func authorize(loginService: LoginService, at server: URL, viewController: UIViewController, success: @escaping (OAuthCredentials) -> Void, failure: @escaping () -> Void) -> Bool {
        print("am here")
        guard let callbackUrl = callbackUrl(for: loginService, server: server) else {
            print("callbackurl not working")
            failure()
            return false
        }
        guard let oauthSwift = oauth1Swift(for: loginService) else {
            print("oauthswift not working ")
            failure()
            return false
        }
        guard let authorizeUrlString = loginService.authorizeUrl else {
            print("authorizeUrlString not working  ")
            failure()
            return false
        }
        guard let authorizeUrl = URL(string: authorizeUrlString) else {
            failure()
            return false
        }
        let handler = OAuthViewController(authorizeUrl: authorizeUrl, callbackUrl: callbackUrl, success: success, failure: failure)
        viewController.navigationController?.pushViewController(handler, animated: true)

        oauthSwift.removeCallbackNotificationObserver()
        oauthSwift.authorizeURLHandler = handler
        self.oauth1Swift = oauthSwift

        return oauthSwift.authorize(withCallbackURL: callbackUrl, success: { _, _, _  in }, failure: { _ in
            failure()
        }) != nil
        /**
        return oauthSwift.authorize(withCallbackURL: callbackUrl, scope: scope, state: state, success: { _, _, _  in }, failure: { _ in
            failure()
        }) != nil
         **/
    }

    static func credentialsForUrlFragment(_ fragment: String) -> OAuthCredentials? {
        guard let normalizedFragment = fragment.removingPercentEncoding else {
            return nil
        }

        let fragmentJSON = JSON(parseJSON: normalizedFragment)

        if let credentials = OAuthCredentials(json: fragmentJSON) {
            return credentials
        }

        return nil
    }

    static func callbackUrl(for loginService: LoginService, server: URL) -> URL? {
        guard
            let host = server.host,
            let callbackPath = loginService.callbackPath ?? loginService.service
        else {
            return nil
        }

        return URL(string: "https://\(host)/_oauth/\(callbackPath)")
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
            responseType: "code"
        )
    }

    static func oauth1Swift(for loginService: LoginService) -> OAuth1Swift? {
            print(loginService.type)
            guard let consumerKey = loginService.clientId else {
                print("consumerKey not working")
                return nil
            }
            guard let requestTokenUrl = loginService.requestTokenUrl else {
                print("requestTokenUrl not working")
                return nil
            }
            guard let authorizeUrl = loginService.authorizeUrl else {
                print("authorizeUrl not working")
                return nil
            }
            guard let accessTokenUrl = loginService.accessTokenUrl else {
                print("accessTokenUrl not working")
                return nil
            }
        return OAuth1Swift(
            consumerKey: consumerKey,
            consumerSecret: "",
            requestTokenUrl: requestTokenUrl,
            authorizeUrl: authorizeUrl,
            accessTokenUrl: accessTokenUrl
        )
    }
}
