//
//  OAuthViewController.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 10/18/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import OAuthSwift
import UIKit
import WebKit

class OAuthViewController: OAuthWebViewController {

    var authorizeUrl: URL?
    var callbackUrl: URL?

    var userAgent: String?

    var success: ((OAuthCredentials) -> Void)?
    var failure: (() -> Void)?

    convenience init(authorizeUrl: URL, callbackUrl: URL, userAgent: String? = nil, success: @escaping (OAuthCredentials) -> Void, failure: @escaping () -> Void) {
        self.init()
        self.authorizeUrl = authorizeUrl
        self.callbackUrl = callbackUrl
        self.userAgent = userAgent
        self.success = success
        self.failure = failure
    }

    lazy var webView: WKWebView = {
        let webView = WKWebView(frame: view.bounds)
        webView.customUserAgent = userAgent
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-0-[view]-0-|", options: [], metrics: nil, views: ["view": webView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: [], metrics: nil, views: ["view": webView]))
        return webView
    }()

    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        activityIndicator.layer.cornerRadius = 10
        activityIndicator.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        return activityIndicator
    }()

    override func handle(_ url: URL) {
        let req = URLRequest(url: url)
        webView.load(req)
    }
}

extension OAuthViewController: WKNavigationDelegate {
    func oauthCredentials(from url: URL) -> OAuthCredentials? {
        guard let fragment = url.fragment else {
            return nil
        }

        return OAuthManager.credentialsForUrlFragment(fragment)
    }

    func isCallback(url: URL) -> Bool {
        return url.host == callbackUrl?.host && url.path == callbackUrl?.path
    }

    @discardableResult
    func willNavigate(_ webView: WKWebView, to url: URL?, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) -> Bool {
        decisionHandler(.allow)
        guard let url = url, isCallback(url: url) else { return false }

        if url.fragment != nil {
            if let credentials = oauthCredentials(from: url) {
                success?(credentials)
            } else if !url.absoluteString.contains("code=") {
                failure?()
            }

            dismissWebViewController()
        }

        return true
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        willNavigate(webView, to: navigationAction.request.url, decisionHandler: decisionHandler)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        dismissWebViewController()
    }
}
