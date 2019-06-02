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
    case showNewWorkspace
    case signup
    case login
    case updateStatus
    case replyNotification
    case openAdmin
    case directory(searchType: String, workspace: String)
    case screenView(screenName: String)
    case messageSent(subscriptionType: String, server: String)
    case mediaUpload(mediaType: String, subscriptionType: String)
    case reaction(subscriptionType: String)
    case serverSwitch(server: String, serverCount: Int)
    case updatedSubscriptionSorting(sorting: String, grouping: String)
    case updatedWebBrowser(browser: String)
    case updatedTheme(theme: String)
    case jitsiVideoCall(subscriptionType: String, server: String)
    case audioMessage(subscriptionType: String)
}

enum UserProperty {
    case server(server: String)

    var propertyName: String {
        switch self {
        case .server:
            return "Server"
        }
    }
}

struct AnalyticsManager {
    static func set(userProperty: UserProperty) {
        // Make sure the user has opted in for sending his usage data
        guard !AnalyticsCoordinator.isUsageDataLoggingDisabled else {
            return
        }

        switch userProperty {
        case let .server(server):
            Analytics.setUserProperty(server, forName: userProperty.propertyName)
        }
    }

    static func log(event: Event) {
        // Make sure the user has opted in for sending his usage data
        guard !AnalyticsCoordinator.isUsageDataLoggingDisabled else {
            return
        }

        // Don't log screen views when using firebase since it already logs them automatically
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
    // swiftlint:disable cyclomatic_complexity
    func name(for provider: AnalyticsProvider? = nil) -> String {
        switch self {
        case .signup:
            return provider == .firebase ? AnalyticsEventSignUp : "sign_up"
        case .login:
            return provider == .firebase ? AnalyticsEventLogin : "login"
        case .showNewWorkspace: return "show_new_workspace"
        case .updateStatus: return "status_update"
        case .replyNotification: return "reply_notification"
        case .openAdmin: return "open_admin"
        case .screenView: return "screen_view"
        case .messageSent: return "message_sent"
        case .mediaUpload: return "media_upload"
        case .reaction: return "reaction"
        case .directory: return "directory"
        case .serverSwitch: return "server_switch"
        case .updatedSubscriptionSorting: return "updated_subscriptions_sorting"
        case .updatedWebBrowser: return "updated_web_browser"
        case .updatedTheme: return "updated_theme"
        case .jitsiVideoCall: return "jitsi_video_call"
        case .audioMessage: return "audio_message"
        }
    }

    func parameters(for provider: AnalyticsProvider) -> [String: Any]? {
        switch self {
        case let .screenView(screenName):
            return ["screen": screenName]
        case let .reaction(subscriptionType):
            return ["subscription_type": subscriptionType]
        case let .directory(searchType, workspace):
            return ["search_type": searchType, "workspace": workspace]
        case let .messageSent(subscriptionType, server):
            return ["subscription_type": subscriptionType, "server": server]
        case let .mediaUpload(mediaType, subscriptionType):
            return ["media_type": mediaType, "subscription_type": subscriptionType]
        case let .serverSwitch(server, serverCount):
            return ["server_url": server, "server_count": serverCount]
        case let .updatedSubscriptionSorting(sorting, grouping):
            return ["sorting": sorting, "grouping": grouping]
        case let .updatedWebBrowser(browser):
            return ["web_browser": browser]
        case let .updatedTheme(theme):
            return ["theme": theme]
        case let .jitsiVideoCall(subscriptionType, server):
            return ["subscription_type": subscriptionType, "server": server]
        case let .audioMessage(subscriptionType):
            return ["subscription_type": subscriptionType]
        default:
            return nil
        }
    }
}
