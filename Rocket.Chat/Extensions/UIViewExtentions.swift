//
//  UIViewExtentions.swift
//  Rocket.Chat
//
//  Created by Rafael Machado on 12/10/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import UIKit

extension UIView {

    static var nib: UINib {
        return UINib(nibName: "\(self)", bundle: nil)
    }

    static func instantiateFromNib() -> Self? {
        func instanceFromNib<T: UIView>() -> T? {
            return nib.instantiate() as? T
        }

        return instanceFromNib()
    }

}

/**
    Credits: The UIView extension below is a well thought snipped authored by @starki
    at StackOverflow: https://stackoverflow.com/questions/47053727/how-to-find-your-own-constraint
 **/

extension UIView {
    func getAllConstraints() -> [NSLayoutConstraint] {
        var views = [self]

        var view = self
        while let superview = view.superview {
            views.append(superview)
            view = superview
        }

        return views.flatMap({ $0.constraints }).filter { constraint in
            return constraint.firstItem as? UIView == self ||
                constraint.secondItem as? UIView == self
        }
    }

    func getWidthConstraints() -> [NSLayoutConstraint] {
        return getAllConstraints().filter({
            ($0.firstAttribute == .width && $0.firstItem as? UIView == self) ||
                ($0.secondAttribute == .width && $0.secondItem as? UIView == self)
        })
    }

    func changeWidth(to value: CGFloat) {
        getAllConstraints().filter({
            $0.firstAttribute == .width &&
                $0.relation == .equal &&
                $0.secondAttribute == .notAnAttribute
        }).forEach({ $0.constant = value })
    }

    func changeLeading(to value: CGFloat) {
        getAllConstraints().filter({
            $0.firstAttribute == .leading &&
                $0.firstItem as? UIView == self
        }).forEach({$0.constant = value})
    }
}
