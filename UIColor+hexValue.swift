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

    static func rocketMainFontColor() -> UIColor {
        
        return UIColor(red: 68/255.0, green: 68/255.0, blue: 68/255.0, alpha: 1)
        
    }
    
    static func rocketSecondaryFontColor() -> UIColor {
        
        return UIColor(red: 127/255.0, green: 127/255.0, blue: 127/255.0, alpha: 1)
        
    }

    static func rocketTimestampColor() -> UIColor {
        
        return UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1)
        
    }
    
    static func rocketRedColor() -> UIColor {
        
        return UIColor(red: 193/255.0, green: 38/255.0, blue: 35/255.0, alpha: 1)
        
    }
    
    static func rocketBlueColor() -> UIColor {
        
        return UIColor(red: 4/255.0, green: 73/255.0, blue: 116/255.0, alpha: 1)
        
    }
    
    static func rocketDarkBlueColor() -> UIColor {
        
        return UIColor(red: 4/255.0, green: 67/255.0, blue: 106/255.0, alpha: 1)

        
    }
    
    
}