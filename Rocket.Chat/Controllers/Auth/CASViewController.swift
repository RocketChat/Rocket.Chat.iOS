//
//  CASViewController.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 1/30/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import WebKit

class CASViewController: UIViewController {
    var baseUrl: URL!
    var loginUrl: URL!
    var callbackUrl: URL!

    var callbackUrlEncoded: String {
        return callbackUrl.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }

    var success: ((String) -> Void)?
    var failure: (() -> Void)?

    convenience init(loginUrl: URL, callbackUrl: URL, success: @escaping (String) -> Void, failure: @escaping () -> Void) {
        self.init()
        self.loginUrl = loginUrl
        self.callbackUrl = callbackUrl
        self.success = success
        self.failure = failure
    }

    lazy var webView: WKWebView = {
        let webView = WKWebView(frame: view.bounds)
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

    override func viewDidLoad() {
        guard let url = URL(string: "\(loginUrl.absoluteString)?service=\(callbackUrlEncoded)") else { return }

        let req = URLRequest(url: url)
        webView.load(req)
    }
}

extension CASViewController: WKNavigationDelegate, Closeable {
    func casCredentialToken(from url: URL) -> String? {
        guard url.path.contains("_cas/") else { return nil }
        return url.lastPathComponent
    }

    func isCallback(url: URL) -> Bool {
        return url.host == callbackUrl?.host && url.path.contains("_cas/")
    }

    @discardableResult
    func willNavigate(_ webView: WKWebView, to url: URL?, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) -> Bool {
        decisionHandler(.allow)
        guard let url = url, isCallback(url: url) else { return false }

        if let credentials = casCredentialToken(from: url) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.success?(credentials)
                self.close(animated: true)
            }
        } else {
            failure?()
            close(animated: true)
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
}
