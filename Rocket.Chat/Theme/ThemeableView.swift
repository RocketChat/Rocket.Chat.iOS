//
//  ThemeableView.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 6/30/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

extension UIView {
    private struct DynamicProperties {
        static var themeableProperties = [String: String]()
    }

    var prop: String {
        get {
            return ""
        }

        set {
            let parsedString = newValue.removingWhitespaces().components(separatedBy: ":")
            guard parsedString.count == 2 else { return }
            themeableProperties[parsedString[0]] = parsedString[1]
        }
    }

    var themeableProperties: [String: String] {
        get {
            return objc_getAssociatedObject(self, &DynamicProperties.themeableProperties) as? [String: String] ?? [:]
        }
        set {
            objc_setAssociatedObject(self, &DynamicProperties.themeableProperties, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
