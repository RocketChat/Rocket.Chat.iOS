//
//  DrawingViewController.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 10.02.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

final class DrawingViewController: UIViewController {
    weak var delegate: DrawingControllerDelegate?

    // Drawing variables
    var lastPoint: CGPoint = .zero
    var leftTopPoint = CGPoint(x: CGFloat.greatestFiniteMagnitude,
                               y: CGFloat.greatestFiniteMagnitude)
    var rightBottomPoint: CGPoint = .zero

    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var brushWidth: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var swiped = false

    @IBOutlet private weak var mainImageView: UIImageView!
    @IBOutlet private weak var tempImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = localized("chat.upload.draw")
        reset()
    }

    @IBAction private func reset() {
        mainImageView.image = nil
        leftTopPoint = CGPoint(x: CGFloat.greatestFiniteMagnitude,
                                   y: CGFloat.greatestFiniteMagnitude)
        rightBottomPoint = .zero
    }

    @IBAction private func endDrawing() {
        let croppedRect = CGRect(x: leftTopPoint.x,
                                 y: leftTopPoint.y,
                                 width: rightBottomPoint.x - leftTopPoint.x,
                                 height: rightBottomPoint.y - leftTopPoint.y)

        UIGraphicsBeginImageContext(croppedRect.size)

        let context = UIGraphicsGetCurrentContext()
        context?.clip(to: CGRect(x: 0,
                                 y: 0,
                                 width: croppedRect.size.width,
                                 height: croppedRect.size.height))

        let drawRect = CGRect(x: -croppedRect.origin.x,
                              y: -croppedRect.origin.y,
                              width: mainImageView.frame.size.width,
                              height: mainImageView.frame.size.height)
        mainImageView.image?.draw(in: drawRect)

        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            dismiss(animated: true, completion: nil)
            UIGraphicsEndImageContext()
            return
        }

        UIGraphicsEndImageContext()

        guard let imageData = UIImageJPEGRepresentation(image, 0.9) else {
            dismiss(animated: true, completion: nil)
            return
        }

        delegate?.finishedEditing(with: UploadHelper.file(for: imageData,
                                                          name: "drawing.jpeg",
                                                          mimeType: "image/jpeg"))
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func closeDrawing() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Drawing

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = false

        if let touch = touches.first {
            lastPoint = touch.location(in: tempImageView)
        }
    }

    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        UIGraphicsBeginImageContext(tempImageView.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }

        tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: tempImageView.frame.size.width, height: tempImageView.frame.size.height))

        context.move(to: fromPoint)
        context.addLine(to: toPoint)
        context.setLineCap(.round)
        context.setLineWidth(brushWidth)
        context.setStrokeColor(red: red, green: green, blue: blue, alpha: 1.0)
        context.setBlendMode(.normal)

        context.strokePath()

        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = opacity
        UIGraphicsEndImageContext()

        // Remember extremes of drawing
        adjustExtremes(for: fromPoint)
        adjustExtremes(for: toPoint)
    }

    private func adjustExtremes(for point: CGPoint) {
        if point.x < leftTopPoint.x {
            leftTopPoint.x = point.x - brushWidth
        } else if point.x > rightBottomPoint.x {
            rightBottomPoint.x = point.x + brushWidth
        }

        if point.y < leftTopPoint.y {
            leftTopPoint.y = point.y - brushWidth
        } else if point.y > rightBottomPoint.y {
            rightBottomPoint.y = point.y + brushWidth
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = true

        if let touch = touches.first {
            let currentPoint = touch.location(in: tempImageView)
            drawLineFrom(fromPoint: lastPoint, toPoint: currentPoint)

            lastPoint = currentPoint
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !swiped {
            drawLineFrom(fromPoint: lastPoint, toPoint: lastPoint)
        }

        // Merge tempImageView into mainImageView
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.draw(in: CGRect(x: 0, y: 0, width: mainImageView.frame.size.width, height: mainImageView.frame.size.height), blendMode: .normal, alpha: 1.0)
        tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: tempImageView.frame.size.width, height: tempImageView.frame.size.height), blendMode: .normal, alpha: opacity)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        tempImageView.image = nil
    }

}
