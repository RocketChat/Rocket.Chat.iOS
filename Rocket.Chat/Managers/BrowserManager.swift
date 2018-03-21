//
//  BrowserManager.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 21/03/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import SafariServices

enum BrowserApp: String {
    case safari, inAppSafari, chrome

    internal enum URLScheme: String {
        case http = "http://", https = "https://", chrome = "googlechrome://", chromeSecure = "googlechromes://"
    }

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
        default:
            break
        }

        return URL(string: absoluteString)
    }
}

extension BrowserApp {
    func open(url: URL) {
        guard let url = appSchemeURL(forURL: url) else { return }

        switch self {
        case .safari, .chrome:
            UIApplication.shared.open(url)
        case .inAppSafari:
            let controller = SFSafariViewController(url: url)
            UIWindow.topWindow.rootViewController?.present(controller, animated: true, completion: nil)
        }
    }
}

struct BrowserManager {
    static let defaultBrowserKey = "DefaultBrowserKey"
    static var browser: BrowserApp {
        guard
            let browserRaw = UserDefaults.standard.string(forKey: defaultBrowserKey),
            let defaultBrowser = BrowserApp(rawValue: browserRaw)
        else {
            return .inAppSafari
        }

        return defaultBrowser
    }


    static func open(url: URL) {
        browser.open(url: url)
    }
}
