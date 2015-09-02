//
//  UIColor+hexValue.swift
//  Rocket.Chat.iOS
//
//  Created by Kornelakis Michael on 9/2/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit


extension UIColor {
    
    static func colorWithHexValue(redValue: CGFloat, greenValue: CGFloat, blueValue: CGFloat, alpha: CGFloat) -> UIColor {
        
        return UIColor(red: redValue/255.0, green: greenValue/255.0, blue: blueValue/255.0, alpha: alpha)
    
    }

}