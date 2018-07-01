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

    open override func setValue(_ value: Any?, forUndefinedKey key: String) {
        assertionFailure("Trying to set value for an undefined key: \(key)")
    }

    /**
     Applies theming properties defined using the User Defined Runtime Attributes in Interface Builder.

     This method is already called in the base implementation of `applyTheme`. When overriding `applyTheme` if `super.applytheme` is not called, it is recommended that `applyThemeFromRuntimeAttributes` be called somewhere in the implementation.
    */

    func applyThemeFromRuntimeAttributes() {
        guard let theme = theme else { return }
        themeableProperties.forEach {
            if let value = theme.value(forKey: $0.value) {
                self.setValue(value, forKey: $0.key)
            }
        }
    }
}

extension Theme {
    open override func value(forUndefinedKey key: String) -> Any? {
        assertionFailure("Trying to get value for an undefined key: \(key)")
        return nil
    }
}
