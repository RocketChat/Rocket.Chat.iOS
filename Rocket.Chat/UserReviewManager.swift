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

    var nextDateForReview: Date = Date()
    let nextDateForReviewKey: String = "kNextDateForReview"

    var availableForReview: Bool {
        return nextDateForReview < Date()
    }

    private let defaults = UserDefaults.standard

    init() {
        if let savedDate = defaults.object(forKey: nextDateForReviewKey) as? Date {
            nextDateForReview = savedDate
        } else {
            setNextDateForReview()
        }
    }

    func calculateNextDateForReview() -> Date {
        let week: TimeInterval = 604800
        return Date().addingTimeInterval(week)
    }

    func setNextDateForReview() {
        nextDateForReview = calculateNextDateForReview()
        defaults.set(nextDateForReview, forKey: nextDateForReviewKey)
    }

    func requestReview() {
        if availableForReview {
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            } else {
                // Fallback on earlier versions
            }

            setNextDateForReview()
        }
    }
}
