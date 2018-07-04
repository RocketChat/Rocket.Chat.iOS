//
//  UINavigationBarTransparent.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 6/26/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

extension UINavigationBar {
    func setTransparent() {
        setBackgroundImage(UIImage(), for: .default)
        shadowImage = UIImage()
        isTranslucent = true
    }

    func setNonTransparent() {
        let navigationBar = UINavigationBar(frame: frame)
        setBackgroundImage(navigationBar.backgroundImage(for: .default), for: .default)
        shadowImage = navigationBar.shadowImage
        isTranslucent = false
    }
}
