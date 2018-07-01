//
//  RuntimeAttributesThemeableView.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 6/30/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

extension UIView {
    private struct ThemeableAssociatedObject {
        static var themeableProperties = [String: String]()
    }

    @objc func setThemeColor(_ themeString: String) {
        let parsedComponents = themeString.removingWhitespaces().components(separatedBy: ":")
        guard parsedComponents.count == 2 else { return }
        themeableProperties[parsedComponents[0]] = parsedComponents[1]
    }

    private var themeableProperties: [String: String] {
        get {
            return objc_getAssociatedObject(self, &ThemeableAssociatedObject.themeableProperties) as? [String: String] ?? [:]
        }
        set {
            objc_setAssociatedObject(self, &ThemeableAssociatedObject.themeableProperties, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func applyThemeFromRuntimeAttributes() {
        guard let theme = theme else { return }
        themeableProperties.forEach {
            self.setValue(theme.value(forKey: $0.value), forKey: $0.key)
        }
    }
}
