//
//  BaseView.swift
//  Rocket.Chat
//
//  Created by Rafael Machado on 12/10/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

class BaseView: UIView, NibLoadableView {
    func isReplaceable() -> Bool {
        return false
    }

    override func awakeAfter(using aDecoder: NSCoder) -> Any? {
        if !isReplaceable() || !subviews.isEmpty {
            return self
        }

        let repleacement = type(of: self).instanceFromNib()
        repleacement.tag = tag
        repleacement.frame = frame
        repleacement.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints

        repleacement.addConstraints(migrateConstraintsToView(view: repleacement))

        return repleacement
    }
}
