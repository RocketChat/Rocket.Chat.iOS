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
        themeProperties[parsedComponents[0]] = parsedComponents[1]
    }

    @objc func setThemeColorOverride(_ overrideString: String) {
        let parsedComponents = overrideString.removingWhitespaces().components(separatedBy: ":")
        guard parsedComponents.count == 2 else { return }
        themeOverrideProperties[parsedComponents[0]] = UIColor(hex: parsedComponents[1])
    }

    open override func setValue(_ value: Any?, forUndefinedKey key: String) {
        #if TEST
        print("ASSERTION: Trying to set value for an undefined key: \(key)")
        #else
        assertionFailure("Trying to set value for an undefined key: \(key)")
        #endif
    }

    /**
     Applies theming properties defined using the User Defined Runtime Attributes in Interface Builder.

     This method is already called in the base implementation of `applyTheme`. When overriding `applyTheme` if `super.applytheme` is not called, it is recommended that `applyThemeFromRuntimeAttributes` be called somewhere in the implementation.
    */

    func applyThemeFromRuntimeAttributes() {
        guard let theme = theme else { return }
        themeProperties.forEach {
            if let value = theme.value(forKey: $0.value) {
                self.setValue(value, forKey: $0.key)
            }
        }
        themeOverrideProperties.forEach {
            self.setValue($0.value, forKey: $0.key)
        }
    }
}

extension UIView {
    private struct ThemeAssociatedObject {
        static var themeProperties = [String: String]()
        static var themeOverrideProperties = [String: UIColor]()
    }

    internal var themeProperties: [String: String] {
        get {
            return objc_getAssociatedObject(self, &ThemeAssociatedObject.themeProperties) as? [String: String] ?? [:]
        }
        set {
            objc_setAssociatedObject(self, &ThemeAssociatedObject.themeProperties, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    internal var themeOverrideProperties: [String: UIColor] {
        get {
            return objc_getAssociatedObject(self, &ThemeAssociatedObject.themeOverrideProperties) as? [String: UIColor] ?? [:]
        }
        set {
            objc_setAssociatedObject(self, &ThemeAssociatedObject.themeOverrideProperties, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension Theme {
    open override func value(forUndefinedKey key: String) -> Any? {
        #if TEST
        print("ASSERTION: Trying to get value for an undefined key: \(key)")
        #else
        assertionFailure("Trying to get value for an undefined key: \(key)")
        #endif
        return nil
    }
}
