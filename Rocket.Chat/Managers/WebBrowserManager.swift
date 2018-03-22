//
//  WebBrowserManager.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 21/03/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import SafariServices

struct WebBrowserManager {
    private static let defaults = UserDefaults.standard
    static let defaultBrowserKey = "DefaultBrowserKey"
    static var browser: WebBrowserApp {
        guard
            let browserRaw = UserDefaults.standard.string(forKey: defaultBrowserKey),
            let browser = WebBrowserApp(rawValue: browserRaw),
            browser.isInstalled
        else {
            return .inAppSafari
        }

        return browser
    }

    static func open(url: URL) {
        browser.open(url: url)
    }

    static func set(defaultBrowser: WebBrowserApp) {
        defaults.set(defaultBrowser.rawValue, forKey: defaultBrowserKey)
    }
}

enum WebBrowserApp: String {
    case safari, inAppSafari, chrome

    internal enum URLScheme: String {
        case http = "http", https = "https", chrome = "googlechrome", chromeSecure = "googlechromes"
    }

    var isInstalled: Bool {
        let urlSuffix = "://"
        switch self {
        case .safari, .inAppSafari:
            return true
        case .chrome:
            guard let url = URL(string: URLScheme.chrome.rawValue + urlSuffix) else { return false }
            return UIApplication.shared.canOpenURL(url)
        }
    }

}

extension WebBrowserApp {
    func appSchemeURL(forURL url: URL) -> URL? {
        let scheme = url.scheme ?? ""
        var absoluteString = url.absoluteString

        switch self {
        case .chrome where scheme == URLScheme.http.rawValue:
            absoluteString = absoluteString.replacingOccurrences(
                of: URLScheme.http.rawValue,
                with: URLScheme.chrome.rawValue
            )
        case .chrome where scheme == URLScheme.https.rawValue:
            absoluteString = absoluteString.replacingOccurrences(
                of: URLScheme.https.rawValue,
                with: URLScheme.chromeSecure.rawValue
            )
        case .chrome where scheme.isEmpty:
            absoluteString = "\(URLScheme.chromeSecure)\(absoluteString)"
        default:
            break
        }

        return URL(string: absoluteString)
    }

    func open(url: URL) {
        guard let url = appSchemeURL(forURL: url) else { return }

        switch self {
        case .safari, .chrome:
            UIApplication.shared.open(url)
        case .inAppSafari:
            func present() {
                let controller = SFSafariViewController(url: url)
                UIWindow.topWindow.rootViewController?.present(controller, animated: true, completion: nil)
            }

            if Thread.isMainThread {
                present()
            } else {
                DispatchQueue.main.async(execute: present)
            }
        }
    }
}
