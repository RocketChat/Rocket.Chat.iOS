//
//  AnalyticsManager.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 27/06/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import Firebase
import Crashlytics

enum AnalyticsProvider {
    case fabric
    case firebase
}

enum Event {
    case signup
    case login
    case screenView(screenName: String)
    case messageSent(subscriptionType: String)
    case mediaUpload(subscriptionType: String)
    case reaction(subscriptionType: String)
    case serverSwitch(serverCount: Int)
    case updatedSubscriptionSorting(options: [String])
    case updatedWebBrowser(browser: String)
    case updatedTheme(theme: String)

}

struct AnalyticsManager {
    static func log(event: Event) {
        // Make sure the user has opted in for sending his usage data
        guard AnalyticsCoordinator.isCrashReportingDisabled else {
            return
        }

        // Don't log screen views when using firebase since it already log it automatically
        if event.name() != Event.screenView(screenName: "").name() {
            Analytics.logEvent(
                event.name(for: .firebase),
                parameters: event.parameters(for: .firebase)
            )
        }

        // Fabric has a specific method for logging login and sign up events
        if event.name() == Event.login.name() {
            Answers.logLogin(
                withMethod: nil,
                success: 1,
                customAttributes: event.parameters(for: .fabric)
            )

            return
        }

        if event.name() == Event.signup.name() {
            Answers.logSignUp(
                withMethod: nil,
                success: 1,
                customAttributes: event.parameters(for: .fabric)
            )

            return
        }

        Answers.logCustomEvent(
            withName: event.name(for: .fabric),
            customAttributes: event.parameters(for: .fabric)
        )
    }
}

extension Event {
    func name(for provider: AnalyticsProvider? = nil) -> String {
        switch self {
        case .signup:
            return provider == .firebase ? AnalyticsEventSignUp : "sign_up"
        case .login:
            return provider == .firebase ? AnalyticsEventLogin : "login"
        case .screenView: return "screen_view"
        case .messageSent: return "message_sent"
        case .mediaUpload: return "media_upload"
        case .reaction: return "reaction"
        case .serverSwitch: return "server_switch"
        case .updatedSubscriptionSorting: return "updated_subscriptions_sorting"
        case .updatedWebBrowser: return "updated_web_browser"
        case .updatedTheme: return "updated_theme"
        }
    }

    func parameters(for provider: AnalyticsProvider) -> [String: Any]? {
        switch self {
        case let .screenView(screenName):
            return ["screen": screenName]
        case let .messageSent(subscriptionType),
             let .mediaUpload(subscriptionType),
             let .reaction(subscriptionType):
            return ["subscription_type": subscriptionType]
        case let .serverSwitch(serverCount):
            return ["server_count": serverCount]
        case let .updatedSubscriptionSorting(options):
            return ["options": options]
        case let .updatedWebBrowser(browser):
            return ["web_browser": browser]
        case let .updatedTheme(theme):
            return ["theme": theme]
        default:
            return nil
        }
    }
}
