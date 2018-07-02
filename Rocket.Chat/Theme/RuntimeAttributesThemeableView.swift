//
//  RuntimeAttributesThemeableView.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 6/30/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

extension UIView {
    @objc func setThemeColor(_ themeString: String) {
        let parsedComponents = themeString.removingWhitespaces().components(separatedBy: ":")
        guard parsedComponents.count == 2 else { return }
        themeableProperties[parsedComponents[0]] = parsedComponents[1]
    }

    @objc func setThemeColorOverride(_ overrideString: String) {
        let parsedComponents = overrideString.removingWhitespaces().components(separatedBy: ":")
        guard parsedComponents.count == 2 else { return }
        themeableOverrideProperties[parsedComponents[0]] = UIColor(hex: parsedComponents[1])
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
        themeableOverrideProperties.forEach {
            self.setValue($0.value, forKey: $0.key)
        }
    }
}

extension UIView {
    private struct ThemeableAssociatedObject {
        static var themeableProperties = [String: String]()
        static var themeableOverrideProperties = [String: UIColor]()
    }

    internal var themeableProperties: [String: String] {
        get {
            return objc_getAssociatedObject(self, &ThemeableAssociatedObject.themeableProperties) as? [String: String] ?? [:]
        }
        set {
            objc_setAssociatedObject(self, &ThemeableAssociatedObject.themeableProperties, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    internal var themeableOverrideProperties: [String: UIColor] {
        get {
            return objc_getAssociatedObject(self, &ThemeableAssociatedObject.themeableOverrideProperties) as? [String: UIColor] ?? [:]
        }
        set {
            objc_setAssociatedObject(self, &ThemeableAssociatedObject.themeableOverrideProperties, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension Theme {
    open override func value(forUndefinedKey key: String) -> Any? {
        assertionFailure("Trying to get value for an undefined key: \(key)")
        return nil
    }
}
