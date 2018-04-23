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
    private static let defaults = UserDefaults.group
    private static let defaultBrowserKey = "DefaultBrowserKey"

    /**
        Returns the default browser the user has choosen to open any links in
        Rocket Chat. If none was choosen the default option is set to .inAppSafari.
     */
    static var browser: WebBrowserApp {
        guard
            let browserRaw = defaults.string(forKey: defaultBrowserKey),
            var browser = WebBrowserApp(rawValue: browserRaw)
        else {
            return .inAppSafari
        }

        if !browser.isInstalled {
            browser = .inAppSafari
            clearDefaultBrowser()
        }

        return browser
    }

    /**
        Open the given URL using the default browser the user has choosen.

        - parameter url: Any URL that can be opened using a web browser app.
     */
    static func open(url: URL) {
        browser.open(url: url)
    }

    /**
        Set the given web browser app as the default option
        to open any links in Rocket Chat.

        - parameter defaultBrowser: One of WebBrowserApp member values.
     */
    static func set(defaultBrowser: WebBrowserApp) {
        defaults.set(defaultBrowser.rawValue, forKey: defaultBrowserKey)
    }

    /**
        Clears the current selected default browser
     */
    static func clearDefaultBrowser() {
        defaults.set(nil, forKey: defaultBrowserKey)
    }
}

enum WebBrowserApp: String {
    case safari, inAppSafari, chrome, opera, firefox

    internal enum URLScheme: String {
        case http = "http", https = "https", chrome = "googlechrome",
            chromeSecure = "googlechromes", opera = "opera-http", firefox = "firefox"
    }

    var name: String {
        switch self {
        case .safari: return localized("web_browser.safari.title")
        case .inAppSafari: return localized("web_browser.in_app_safari.title")
        case .chrome: return localized("web_browser.chrome.title")
        case .opera: return localized("web_browser.opera.title")
        case .firefox: return localized("web_browser.firefox.title")
        }
    }

    var isInstalled: Bool {
        let urlSuffix = "://"
        switch self {
        case .safari, .inAppSafari:
            return true
        case .chrome:
            guard let url = URL(string: URLScheme.chrome.rawValue + urlSuffix) else { return false }
            return UIApplication.shared.canOpenURL(url)
        case .opera:
            guard let url = URL(string: URLScheme.opera.rawValue + urlSuffix) else { return false }
            return UIApplication.shared.canOpenURL(url)
        case .firefox:
            guard let url = URL(string: URLScheme.firefox.rawValue + urlSuffix) else { return false }
            return UIApplication.shared.canOpenURL(url)
        }
    }

}

extension WebBrowserApp {
    private func appSchemeURL(forURL url: URL) -> URL? {
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
            absoluteString = "\(URLScheme.chromeSecure.rawValue)\(absoluteString)"
        case .opera where scheme == URLScheme.http.rawValue || scheme == URLScheme.https.rawValue:
            absoluteString = absoluteString.replacingOccurrences(
                of: URLScheme.http.rawValue,
                with: URLScheme.opera.rawValue
            )
        case .opera where scheme.isEmpty:
            absoluteString = "\(URLScheme.opera.rawValue)\(absoluteString)"
        case .firefox:
            absoluteString = "\(URLScheme.firefox.rawValue)://open-url?url=\(absoluteString)"
        default:
            break
        }

        return URL(string: absoluteString)
    }

    func open(url: URL) {
        guard let url = appSchemeURL(forURL: url) else { return }

        switch self {
        case .safari, .chrome, .opera, .firefox:
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
