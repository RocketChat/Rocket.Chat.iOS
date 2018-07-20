//
//  RuntimeAttributesThemeableView.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 6/30/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

extension UIView {
    /**
     Sets desired theme color on a `UIColor` attribute using a formatted string.

     The color is automatically changed based on the currently applied theme.

     - Important:
     Should only be used with User Defined Runtime Attributes in Interface Builder.

     For more information, please see [Setting theme properties using User Defined Runtime Attributes](https://github.com/RocketChat/Rocket.Chat.iOS/pull/1850)

     - parameters:
        - themeString: contains the attribute of the view, which needs to be themed and the attribute of the theme which represents the desired color, separated with a colon.

            ```
            textColor: auxiliaryText
            ```

            This can be read as `view.textColor = theme.auxiliaryText`
    */

    @objc func setThemeColor(_ themeString: String) {
        let parsedComponents = themeString.removingWhitespaces().components(separatedBy: ":")
        guard parsedComponents.count == 2 else { return }
        themeProperties[parsedComponents[0]] = parsedComponents[1]
    }

    /**
     Sets desired color on a `UIColor` attribute using a formatted string.

     This color stays the same irrespective of the theme currently applied.

     - Important:
     Should only be used with User Defined Runtime Attributes in Interface Builder.

     For more information, please see [Setting theme properties using User Defined Runtime Attributes](https://github.com/RocketChat/Rocket.Chat.iOS/pull/1850)

     - parameters:
        - overrideString: contains the attribute of the view, which needs to be themed and the desired color represented in hex, separated with a colon.

            ```
            backgroundColor: #FFFFFF
            ```

            This can be read as `view.backgroundColor = UIColor(hex: "#FFFFFF")`

            **TIP:** The color can be represented in various forms of hex, (eg. `aaa`, `#ffffff`, `#AAAAAAFF`) and some common color names are also supported (such as `red`, `green`, `blue`). This behavior is adopted from the UIColor extension declared in the `UIColorCSSColorsExtension.swift` file.
     */

    @objc func setThemeColorOverride(_ overrideString: String) {
        let parsedComponents = overrideString.removingWhitespaces().components(separatedBy: ":")
        guard parsedComponents.count == 2 else { return }
        themeOverrideProperties[parsedComponents[0]] = UIColor(hex: parsedComponents[1])
    }

    /**
     Applies theming properties defined using the User Defined Runtime Attributes in Interface Builder.

     This method is already called in the base implementation of `applyTheme`. When overriding `applyTheme` if `super.applytheme` is not called, it is recommended that `applyThemeFromRuntimeAttributes` be called somewhere in the implementation.

     **See also:** [Setting theme properties using User Defined Runtime Attributes](https://github.com/RocketChat/Rocket.Chat.iOS/pull/1850)
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

    open override func setValue(_ value: Any?, forUndefinedKey key: String) {
        #if TEST
        print("ASSERTION: Trying to set value for an undefined key: \(key)")
        #else
        assertionFailure("Trying to set value for an undefined key: \(key)")
        #endif
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
