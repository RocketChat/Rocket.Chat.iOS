//
//  NibLoadableProtocol.swift
//  Rocket.Chat
//
//  Created by Rafael Machado on 12/10/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

/**
 *  A protocol used to load xib files using the class name
 *  In order for that to work the xib and the class file must have the same name, i.e:
 *  MyCustomView.xib
 *  MyCustomView.swift
 *  MyCustomView.h/m
 */
public protocol NibLoadableView: class {
    static var nibName: String { get }
    static func instanceFromNib() -> UIView
    static func instanceFromNibWithName(name: String) -> UIView
}

public extension NibLoadableView where Self: UIView {
    static var nibName: String {
        // In Swift 3 it returns `Rocket_Chat.AvatarView` so we need to extract what we need
        return String(describing: self).components(separatedBy: ".").last ?? ""
    }

    static func instanceFromNib() -> UIView {
        return instanceFromNibWithName(name: self.nibName)
    }

    static func instanceFromNibWithName(name: String) -> UIView {
        return Bundle.main.loadNibNamed(name, owner: nil, options: nil)?.first as? UIView ?? UIView()
    }
}
