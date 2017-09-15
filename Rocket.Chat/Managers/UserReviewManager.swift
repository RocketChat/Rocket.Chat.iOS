//
//  UserReviewManager.swift
//  Rocket.Chat
//
//  Created by Augusto Falcão on 9/14/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import StoreKit

class UserReviewManager {
    static let shared = UserReviewManager()

    let nextDateForReviewKey: String = "kNextDateForReview"

    private let defaults = UserDefaults.standard

    var nextDateForReview: Date {
        get {
            if let date = defaults.object(forKey: nextDateForReviewKey) as? Date {
                return date
            } else {
                let date = calculateNextDateForReview()
                defaults.set(date, forKey: nextDateForReviewKey)
                return date
            }
        }
        set(newDate) {
            defaults.set(newDate, forKey: nextDateForReviewKey)
        }
    }

    var availableForReview: Bool {
        return nextDateForReview < Date()
    }

    func calculateNextDateForReview() -> Date {
        let week: TimeInterval = 30 // 604800
        return Date().addingTimeInterval(week)
    }

    func requestReview() -> Bool {
        if availableForReview {
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            } else {
                // Fallback on earlier versions
            }

            nextDateForReview = calculateNextDateForReview()
            return true
        }
        return false
    }
}
