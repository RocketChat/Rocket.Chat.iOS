//
//  BaseView.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 10/09/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

@IBDesignable class BaseView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        return createFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        return createFromNib()
    }
    
    static func createFromNib() -> Self? {
        guard let nibName = nibName() else { return nil }
        guard let view = NSBundle.mainBundle().loadNibNamed(nibName, owner: nil, options: nil).last as? Self else { return nil }
        return view
    }
    
    static func nibName() -> String? {
        guard let n = NSStringFromClass(Self.self).componentsSeparatedByString(".").last else { return nil }
        return n
    }
    
}
