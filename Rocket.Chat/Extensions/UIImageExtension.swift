//
//  UIImageExtension.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 8/16/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

extension UIImage {

    func imageWithTint(color: UIColor, alpha: CGFloat = 1.0) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.mainScreen().scale)
        
        let context = UIGraphicsGetCurrentContext()

        color.setFill()
        
        CGContextTranslateCTM(context, 0, self.size.height)
        CGContextScaleCTM(context, 1.0, -1.0)
        
        CGContextSetBlendMode(context, CGBlendMode.ColorBurn)
        let rect = CGRectMake(0.0, 0.0, self.size.width, self.size.height)
        CGContextDrawImage(context, rect, self.CGImage)
        
        CGContextSetBlendMode(context, CGBlendMode.SourceIn)
        CGContextAddRect(context, rect)
        CGContextDrawPath(context, CGPathDrawingMode.Fill)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }

}
