//
//  UIViewExtentions.swift
//  Rocket.Chat
//
//  Created by Rafael Machado on 12/10/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import UIKit

/**
 * Easy way to migrate autolayout constraints
 * This is meant to be used in conjunction with NibLoadableView
 */
public extension UIView {

    func migrateToSuperview(superview: UIView) {
        let previousSuperview = self.superview
        let constraints = previousSuperview?.removeConstraintsInvolvingView(view: self) ?? [NSLayoutConstraint]()
        let migratedConstratints = previousSuperview?.migrateConstraints(constraints: constraints, toView: superview) ?? [NSLayoutConstraint]()

        superview.addSubview(self)
        superview.addConstraints(migratedConstratints)
    }

    func migrateConstraintsToView(view: UIView) -> [NSLayoutConstraint] {

        return migrateConstraints(constraints: constraints, toView: view)
    }

    func removeConstraintsInvolvingView(view: UIView) -> [NSLayoutConstraint] {
        let constraints = constraintsInvolvingView(view: view)
        removeConstraints(constraints)
        return constraints
    }

    func migrateConstraints(constraints: [NSLayoutConstraint], toView view: UIView) -> [NSLayoutConstraint] {
        if constraints.count <= 0 {
            return []
        }

        return constraints.map { constraint in
            return migrateConstraint(constraint: constraint, toView: view)
        }
    }

    func constraintsInvolvingView(view: UIView) -> [NSLayoutConstraint] {
        return constraints.filter { constraint in
            let firstItem  = (constraint.firstItem as? UIView) ?? UIView()
            let secondItem = (constraint.secondItem as? UIView) ?? UIView()
            return firstItem == view || secondItem == view
        }
    }

    // Helpers

    private func migrateConstraint(constraint: NSLayoutConstraint, toView view: UIView) -> NSLayoutConstraint {
        var firstAttribute  = constraint.firstAttribute
        var secondAttribute = constraint.secondAttribute

        guard let firstItem  = migrateItem(item: constraint.firstItem, attribute:&firstAttribute, toView: view) else {
            return constraint
        }

        let secondItem = migrateItem(item: constraint.secondItem, attribute:&secondAttribute, toView: view)

        return NSLayoutConstraint.init(item:firstItem, attribute: firstAttribute, relatedBy: constraint.relation, toItem: secondItem, attribute: secondAttribute, multiplier: constraint.multiplier, constant: constraint.constant)
    }

    private func migrateItem(item: AnyObject?, attribute anAttribute:inout NSLayoutAttribute, toView view: UIView) -> AnyObject? {
        var result = item

        if (item as? NSObject) == self {
            result = view
        } else if let _ = item as? UILayoutSupport {
            result = view
            anAttribute = invertAttribute(attribute: anAttribute)
        }

        return result
    }

    private func invertAttribute(attribute: NSLayoutAttribute) -> NSLayoutAttribute {
        switch attribute {
        case .top:
            return .bottom
        case .bottom:
            return .top
        default:
            return attribute
        }
    }
}
