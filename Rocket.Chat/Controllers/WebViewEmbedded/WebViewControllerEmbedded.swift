//
//  WebViewControllerEmbedded.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 11/24/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import WebKit

final class WebViewControllerEmbedded: UIViewController {

    var urlLoaded = false
    var url: URL?
    weak var webView: WKWebView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var navigationBar: UINavigationBar!

    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        activityIndicator.layer.cornerRadius = 10
        activityIndicator.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        return activityIndicator
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !urlLoaded {
            if let url = url?.removingDuplicatedSlashes() {
                let request = URLRequest(url: url)

                let webView = WKWebView(frame: containerView.frame)

                webView.navigationDelegate = self
                webView.load(request)
                containerView.addSubview(webView)

                view.addConstraints(
                    NSLayoutConstraint.constraints(
                        withVisualFormat: "|-0-[view]-0-|", options: [], metrics: nil, views: ["view": webView]
                    )
                )

                view.addConstraints(
                    NSLayoutConstraint.constraints(
                        withVisualFormat: "V:|-0-[view]-0-|", options: [], metrics: nil, views: ["view": webView]
                    )
                )

                webView.translatesAutoresizingMaskIntoConstraints = false
                containerView.translatesAutoresizingMaskIntoConstraints = false

                self.webView = webView
                self.urlLoaded = true
                self.activityIndicator.startAnimating()
            }
        }
    }

    @IBAction func donePressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension WebViewControllerEmbedded: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()

        let token = AuthManager.isAuthenticated()?.token ?? ""

        //swiftlint:disable
        let authenticationJavaScriptMethod = "Meteor.loginWithToken('\(token)', function() { })"
        //swiftlint:enable

        webView.evaluateJavaScript(authenticationJavaScriptMethod) { (_, _) in
            // Do nothing
        }
    }

}
