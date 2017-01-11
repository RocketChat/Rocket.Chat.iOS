//
//  UIImageExtension.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 8/16/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

extension UIImage {

    func imageWithTint(_ color: UIColor, alpha: CGFloat = 1.0) -> UIImage {

        guard let cgImage = cgImage else { return self }

        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)

        let context = UIGraphicsGetCurrentContext()

        color.setFill()

        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)

        context?.setBlendMode(CGBlendMode.colorBurn)
        let rect = CGRect(x: 0.0, y: 0.0, width: self.size.width, height: self.size.height)
        context?.draw(cgImage, in: rect)

        context?.setBlendMode(CGBlendMode.sourceIn)
        context?.addRect(rect)
        context?.drawPath(using: CGPathDrawingMode.fill)

        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let image = img else { return self }
        return image
    }

}
