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

    static func callbackURL(for loginService: LoginService, at server: URL) -> URL? {
        guard let service = loginService.service else { return nil }
        return URL(string: "https://\(server.host ?? "")/_oauth/\(service)")
    }

    static func authorize(loginService: LoginService, at server: URL, viewController: UIViewController, success: @escaping (OAuthCredentials) -> Void, failure: @escaping () -> Void) {
        guard
            let host = loginService.serverURL, !host.isEmpty,
            let clientId = loginService.clientId,
            let authorizePath = loginService.authorizePath,
            let tokenPath = loginService.tokenPath,
            let callbackURL = callbackURL(for: loginService, at: server)
        else {
            return
        }

        oauthSwift = OAuth2Swift(
            consumerKey: clientId,
            consumerSecret: "",
            authorizeUrl: "\(host)\(authorizePath)",
            accessTokenUrl: "\(host)\(tokenPath)",
            responseType: "token"
        )

        guard let oauthSwift = oauthSwift else { return }

        let handler = WebViewController()
        oauthSwift.removeCallbackNotificationObserver()
        handler.targetURL = URL(string: "\(host)\(authorizePath)")
        handler.viewDidLoad()
        viewController.navigationController?.pushViewController(handler, animated: true)
        handler.didNavigate = { purl in
            guard let purl = purl else { return false }
            guard var urlComponents = URLComponents(url: purl, resolvingAgainstBaseURL: true) else { return true }

            urlComponents.query = urlComponents.query?.removingPercentEncoding

            guard let url = urlComponents.url else { return true }

            if url.host == callbackURL.host && url.path == callbackURL.path, let fragment = url.fragment {
                let fragmentJSON = JSON(parseJSON: NSString(string: fragment).removingPercentEncoding ?? "")

                guard let credentials = OAuthCredentials(json: fragmentJSON) else {
                    failure()
                    return true
                }

                success(credentials)
                return true
            }
            return false
        }
        oauthSwift.authorizeURLHandler = handler

        let state = "{\"loginStyle\":\"popup\",\"credentialToken\":\"\(String.random(40))\",\"isCordova\":true}".base64Encoded()
        oauthSwift.authorize(withCallbackURL: callbackURL, scope: loginService.scope ?? "",
                             state: state ?? "", success: { _,_,_  in }, failure: { _ in failure() })
    }
}
