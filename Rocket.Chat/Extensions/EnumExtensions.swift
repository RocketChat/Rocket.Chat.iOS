//
//  EnumExtensions.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 18.04.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

#if swift(>=4.2)
fatalError("Remove CaseIterable. This should be implemented in Swift 4.2.")
#else
protocol CaseIterable {
    associatedtype AllCases: Collection where AllCases.Element == Self
    static var allCases: AllCases { get }
}

extension CaseIterable where Self: Hashable {
    static var allCases: [Self] {
        return [Self](AnySequence { () -> AnyIterator<Self> in
            var raw = 0
            return AnyIterator {
                let current = withUnsafeBytes(of: &raw) { $0.load(as: Self.self) }
                guard current.hashValue == raw else {
                    return nil
                }
                raw += 1
                return current
            }
        })
    }
}
#endif

protocol LocalizableEnum {
    var localizedCase: String { get }
}

extension SubscriptionNotificationsStatus: LocalizableEnum {
    var localizedCase: String {
        return localized("subscription.notifications.status.\(rawValue)")
    }

}

extension SubscriptionNotificationsAudioValue: LocalizableEnum {
    var localizedCase: String {
        return localized("subscription.notifications.audio.value.\(rawValue)")
    }

}
