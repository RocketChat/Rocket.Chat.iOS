//
//  WebViewControllerEmbedded.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 11/24/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import WebKit

class WebViewControllerEmbedded: UIViewController {

    var url: URL?
    weak var webView: WKWebView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let url = url {
            let request = URLRequest(url: url)

            let webView = WKWebView(frame: view.frame)
            webView.navigationDelegate = self
            webView.load(request)
            view.addSubview(webView)

            self.webView = webView
        }
    }

}

extension WebViewControllerEmbedded: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let token = AuthManager.isAuthenticated()?.token ?? ""

        let authenticationJavaScriptMethod = """
        Meteor.loginWithToken("\(token)", function() {
            console.log('Iframe command [login-with-token]: result', arguments);
        });
        """

        webView.evaluateJavaScript(authenticationJavaScriptMethod) { (response, error) in
            dump(response)
            dump(error)
        }
    }

}
