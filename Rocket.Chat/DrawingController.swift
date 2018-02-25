//
//  DrawingController.swift
//  Rocket.Chat
//
//  Created by Anirudh Vajjala on 23/02/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices
extension DrawingViewController {
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = true
        if let touch=touches.first {
            var currentPoint = touch.location(in: self.view)
            drawLines(fromPoint: lastPoint, toPoint: currentPoint)
            lastPoint = currentPoint
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !swiped {
            drawLines(fromPoint: lastPoint , toPoint: lastPoint)
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = false
        if let touch = touches.first {
            lastPoint = touch.location(in: self.view)
        }      
    }
    func drawLines(fromPoint: CGPoint , toPoint: CGPoint) {
        UIGraphicsBeginImageContext(self.view.frame.size)
        imageView?.image?.draw(in: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        var context = UIGraphicsGetCurrentContext()
        context?.move(to: CGPoint(x: fromPoint.x , y: fromPoint.y))
        context?.addLine(to: CGPoint(x: toPoint.x , y: toPoint.y))
        context?.setBlendMode(CGBlendMode.normal)
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth((40-2)*brushsize.value)
        color = color.withAlphaComponent(opacity.value)
        context?.setStrokeColor(color.cgColor)
        context?.strokePath()
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
}
