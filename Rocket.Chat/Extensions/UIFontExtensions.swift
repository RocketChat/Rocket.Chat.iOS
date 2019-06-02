//
//  UIFontExtensions.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/12/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

extension UIFont {
    func withTraits(_ traits: UIFontDescriptor.SymbolicTraits...) -> UIFont? {
        if let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits)) {
            return UIFont(descriptor: descriptor, size: 0)
        }
        return nil
    }

    func bold() -> UIFont? {
        return withTraits(.traitBold)
    }

    func italic() -> UIFont? {
        return withTraits(.traitItalic)
    }

    func boldItalic() -> UIFont? {
        return withTraits(.traitBold, .traitItalic)
    }

    func semibold() -> UIFont? {
        return UIFont.systemFont(ofSize: self.pointSize, weight: .semibold)
    }

}
