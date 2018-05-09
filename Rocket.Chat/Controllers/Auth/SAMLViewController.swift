//
//  SAMLViewController.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 2/9/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import WebKit

class SAMLViewController: UIViewController {
    var serverUrl: URL!
    var provider: String = ""

    var completed: Bool = false

    var success: ((String) -> Void)?
    var failure: (() -> Void)?

    let credentialToken = String.random(17)

    convenience init(serverUrl: URL, provider: String, success: @escaping (String) -> Void, failure: @escaping () -> Void) {
        self.init()
        self.serverUrl = serverUrl
        self.provider = provider
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
        guard
            let url = URL(string: "\(serverUrl.absoluteString)/_saml/authorize/\(provider)/\(credentialToken)")
        else {
            failure?()
            return
        }

        let req = URLRequest(url: url)
        webView.load(req)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if !completed {
            failure?()
        }
    }
}

extension SAMLViewController: WKNavigationDelegate, Closeable {
    func isCallback(url: URL) -> Bool {
        return url.host == serverUrl.host && url.path == "/_saml/validate/\(provider)"
    }

    @discardableResult
    func willNavigate(_ webView: WKWebView, to url: URL?, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) -> Bool {
        decisionHandler(.allow)
        guard let url = url, isCallback(url: url) else { return false }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.completed = true
            self?.success?(self?.credentialToken ?? "")
            self?.close(animated: true)
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
