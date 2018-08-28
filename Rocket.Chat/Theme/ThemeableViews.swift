//
//  ThemeableViews.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 5/2/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import SlackTextViewController

extension UIView: Themeable {

    /**
     Applies theme to the view and all of its `subviews`.

     The `Theme` returned from the `theme` property is used. To exempt a view from getting themed, override the `theme` property and return `nil`.

     The default implementation calls the `applyTheme` method on all of its subviews, and sets the background color of the views.

     Override this method to adapt the components of the view to the theme currently applied.

     `super.applyTheme` should be called somewhere in the implementation to automatically call `applyTheme` on all of the subviews, set the `backgroundColor` according to the theme and the `UIColor` attributes defined in Runtime Attributes.

     This method should only be called directly if the view or any of its subviews require theming after the first initialization.

     - Important:
     It is recommended that this method be only overridden, if it's not possible to use User Defined Runtime Attributes to achieve the desired result. For more information, please see [Setting theme properties using Runtime Attributes](https://github.com/RocketChat/Rocket.Chat.iOS/pull/1850).

     On first initializaiton, it is recommended that the view controller for the view be added as an observer to the ThemeManager using the `ThemeManager.addObserver(_:)` method. If a view controller does not exist, the view should be added as an observer instead.

     **See also:** [Theming Rocket.Chat](https://github.com/RocketChat/Rocket.Chat.iOS/pull/1602)
     */

    func applyTheme() {
        applyThemeBackgroundColor()
        self.subviews.forEach { $0.applyTheme() }
        applyThemeFromRuntimeAttributes()
    }

    func applyThemeBackgroundColor() {
        guard let theme = theme else { return }
        backgroundColor = theme.backgroundColor.withAlphaComponent(backgroundColor?.cgColor.alpha ?? 0.0)
    }
}

extension UIView: ThemeProvider {

    /**
     Returns the theme to be allied to the view.

     By default the `theme` of the `superview` is returned. If a `superview` does not exits, then the value is taken from `ThemeManager.theme`

     Overriding this property and returning `nil` will exempt the view from getting themed.
     */

    var theme: Theme? {
        let exemptedInternalViews = [
            "UISwipeActionStandardButton",
            "_UIAlertControllerView"
        ]

        let exemptedExternalViews = [
            "SwipeCellKit.SwipeActionsView"
        ]

        guard !(exemptedInternalViews + exemptedExternalViews).contains(type(of: self).description()) else { return nil }
        guard let superview = superview else { return ThemeManager.theme }
        if type(of: self).description() == "_UIPopoverView" { return themeForPopover }
        return superview.theme
    }

    private var themeForPopover: Theme? {
        guard let theme = superview?.theme else { return nil }
        return Theme(
            backgroundColor: theme.focusedBackground,
            focusedBackground: theme.focusedBackground,
            auxiliaryBackground: theme.auxiliaryBackground,
            bannerBackground: theme.bannerBackground,
            titleText: theme.titleText,
            bodyText: theme.bodyText,
            controlText: theme.controlText,
            auxiliaryText: theme.auxiliaryText,
            tintColor: theme.tintColor,
            auxiliaryTintColor: theme.auxiliaryTintColor,
            hyperlink: theme.hyperlink,
            mutedAccent: theme.mutedAccent,
            strongAccent: theme.strongAccent,
            appearence: theme.appearence
        )
    }
}

// MARK: UIKit class extensions

extension UILabel {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }
        textColor = theme.titleText
        applyThemeFromRuntimeAttributes()
    }
}

extension UIButton {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }
        setTitleColor(theme.tintColor, for: .normal)
        tintColor = theme.tintColor
        themeTextFieldClearButton()
        applyThemeFromRuntimeAttributes()
    }

    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        themeTextFieldClearButton()
    }

    private func themeTextFieldClearButton() {
        guard
            let textField = superview as? UITextField,
            let theme = theme,
            textField.clearButton === self,
            type(of: textField).description() != "UISearchBarTextField"
        else {
            return
        }

        self.setImage(self.image(for: .normal)?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.tintColor = theme.titleText
    }
}

extension UITextField {
    override func applyTheme() {
        guard let theme = theme else { return }
        textColor = theme.titleText
        tintColor = theme.tintColor
        keyboardAppearance = theme.appearence.keyboardAppearence
        leftView?.tintColor = theme.auxiliaryText
        if let placeholder = placeholder {
            attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: theme.auxiliaryText])
        }
        applyThemeFromRuntimeAttributes()
    }
}

// Due to a possible bug in iOS, search bars with .minimal
// style are not able to be themed. Use .prominent or .default
// searchBarStyle instead.
extension UISearchBar {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }
        if #available(iOS 11, *) {
            barStyle = theme.appearence.barStyle
        }

        backgroundImage = UIImage()
        textField?.backgroundColor = #colorLiteral(red: 0.4980838895, green: 0.4951269031, blue: 0.5003594756, alpha: 0.1525235445)
        applyThemeFromRuntimeAttributes()
    }
}

extension UIActivityIndicatorView {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }
        color = theme.bodyText
        applyThemeFromRuntimeAttributes()
    }

    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        applyTheme()
    }
}

extension UIRefreshControl {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }
        tintColor = theme.bodyText
        applyThemeFromRuntimeAttributes()
    }
}

extension UICollectionView {
    open override func insertSubview(_ view: UIView, at index: Int) {
        super.insertSubview(view, at: index)
        view.applyTheme()
    }

    open override func addSubview(_ view: UIView) {
        super.addSubview(view)
        view.applyTheme()
    }
}

extension UITableView {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }
        backgroundColor = style == .grouped ? theme.auxiliaryBackground : theme.backgroundColor
        separatorColor = theme.mutedAccent
        applyThemeFromRuntimeAttributes()
    }

    open override func insertSubview(_ view: UIView, at index: Int) {
        super.insertSubview(view, at: index)
        view.applyTheme()
    }

    open override func addSubview(_ view: UIView) {
        super.addSubview(view)
        view.applyTheme()
    }
}

extension UITableViewCell {
    override func applyTheme() {
        subviews.filter { type(of: $0).description() != "_UITableViewCellSeparatorView" }
            .forEach { $0.applyTheme() }
        guard let theme = theme else { return }
        backgroundColor = theme.backgroundColor.withAlphaComponent(backgroundColor?.cgColor.alpha ?? 0.0)
        detailTextLabel?.textColor = theme.auxiliaryText
        tintColor = theme.tintColor
        applyThemeFromRuntimeAttributes()
    }

    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard superview != nil else { return }
        applyTheme()
    }
}

extension UITableViewHeaderFooterView {
    override func applyTheme() {
        super.applyTheme()
        textLabel?.textColor = #colorLiteral(red: 0.431372549, green: 0.431372549, blue: 0.4509803922, alpha: 1)
        applyThemeFromRuntimeAttributes()
    }
}

extension UITextView {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }
        tintColor = theme.hyperlink
        applyThemeFromRuntimeAttributes()
    }
}

extension UINavigationBar {
    override func applyTheme() {
        guard let theme = theme else { return }
        tintColor = theme.tintColor
        barStyle = theme.appearence.barStyle
        barTintColor = theme.focusedBackground
        items?.forEach { $0.titleView?.applyTheme() }
        applyThemeFromRuntimeAttributes()
    }

    open override func insertSubview(_ view: UIView, at index: Int) {
        super.insertSubview(view, at: index)
        view.applyTheme()
    }
}

extension UIToolbar {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }
        isTranslucent = false
        barTintColor = theme.focusedBackground
        tintColor = theme.tintColor
        barStyle = theme.appearence.barStyle
        applyThemeFromRuntimeAttributes()
    }

    open override func insertSubview(_ view: UIView, at index: Int) {
        super.insertSubview(view, at: index)
        view.applyTheme()
    }
}

extension UITabBar {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }
        barTintColor = theme.focusedBackground
        tintColor = theme.tintColor
        barStyle = theme.appearence.barStyle
        applyThemeFromRuntimeAttributes()
    }

    open override func insertSubview(_ view: UIView, at index: Int) {
        super.insertSubview(view, at: index)
        view.applyTheme()
    }
}

extension UIScrollView {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }
        indicatorStyle = theme.appearence.scrollViewIndicatorStyle
        applyThemeFromRuntimeAttributes()
    }
}

extension UIPickerView {
    override func applyTheme() {
        guard let theme = theme else { return }
        applyThemeBackgroundColor()
        subviews.forEach {
            if $0.frame.height > 0, $0.frame.height < 1 {
                $0.backgroundColor = theme.mutedAccent
            } else {
                $0.applyTheme()
            }
        }
        applyThemeFromRuntimeAttributes()
    }

    open override func insertSubview(_ view: UIView, at index: Int) {
        super.insertSubview(view, at: index)
        applyTheme()
    }
}

// MARK: External class extensions

extension SLKTextInputbar {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }
        textView.keyboardAppearance = theme.appearence.keyboardAppearence
        applyThemeFromRuntimeAttributes()
    }

    open override func insertSubview(_ view: UIView, at index: Int) {
        super.insertSubview(view, at: index)
        view.applyTheme()
    }
}

extension SLKTextView {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }
        layer.borderColor = #colorLiteral(red: 0.497693181, green: 0.494099319, blue: 0.5004472733, alpha: 0.1518210827)
        backgroundColor = #colorLiteral(red: 0.497693181, green: 0.494099319, blue: 0.5004472733, alpha: 0.1021854048)
        textColor = theme.bodyText
        tintColor = theme.tintColor
        applyThemeFromRuntimeAttributes()
    }
}

extension MBProgressHUD {
    override var theme: Theme? { return nil }
}

// MARK: Subclasses

class ThemeableStackView: UIStackView {
    override func addArrangedSubview(_ view: UIView) {
        super.addArrangedSubview(view)
        view.applyTheme()
        applyThemeFromRuntimeAttributes()
    }
}
