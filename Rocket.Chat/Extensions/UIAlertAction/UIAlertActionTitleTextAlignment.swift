//
//  UIAlertActionTitleTextAlignment.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 5/24/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

import UIKit

private let kTitleTextAlignment = "titleTextAlignment"
extension UIAlertAction {
    enum TitleTextAlignment: Int {
        case left = 0
        case center = 1
        case right = 2
    }

    var titleTextAlignment: TitleTextAlignment {
        get {
            guard let rawValue = value(forKey: kTitleTextAlignment) as? Int else {
                return .center
            }

            return TitleTextAlignment(rawValue: rawValue) ?? .center
        }
        set {
            setValue(newValue.rawValue, forKey: kTitleTextAlignment)
        }
    }
}
