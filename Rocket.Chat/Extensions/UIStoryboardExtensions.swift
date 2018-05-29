//
//  UIStoryboardExtensions.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 10/9/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

extension UIStoryboard {

    static func controller(from storyboardName: String, identifier: String) -> UIViewController? {
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: identifier)
    }

}
