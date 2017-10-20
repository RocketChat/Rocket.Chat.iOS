//
//  WebViewController.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 10/18/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import OAuthSwift
import UIKit
import WebKit

class WebViewController: OAuthWebViewController {

    var targetURL: URL?
    var webView: WKWebView!

    var didNavigate: ((URL?) -> Bool)?

    override func viewDidLoad() {
        super.viewDidLoad()

        webView = WKWebView(frame: view.bounds)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-0-[view]-0-|", options: [], metrics: nil, views: ["view": webView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: [], metrics: nil, views: ["view": webView]))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    override func handle(_ url: URL) {
        targetURL = url
        self.loadAddressURL()
    }

    func loadAddressURL() {
        guard let url = targetURL else {
            return
        }
        let req = URLRequest(url: url)
        webView.load(req)
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        if didNavigate?(navigationAction.request.url) ?? false {
            decisionHandler(.allow)
            dismissWebViewController()
            return
        }

        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        dismissWebViewController()
    }
}
