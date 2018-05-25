//
//  UIAlertActionImage.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 5/24/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

private let kImage = "image"
extension UIAlertAction {
    var image: UIImage? {
        get {
            return value(forKey: kImage) as? UIImage
        }
        set {
            setValue(newValue, forKey: kImage)
        }
    }
}
