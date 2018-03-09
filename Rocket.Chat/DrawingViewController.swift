//
//  DrawingViewController.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 10.02.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

final class DrawingViewController: UIViewController {
    @IBOutlet weak var colorItem: UIBarButtonItem!

    weak var delegate: DrawingControllerDelegate?

    // Drawing variables
    private var lastPoint: CGPoint = .zero
    private var leftTopPoint = CGPoint(x: CGFloat.greatestFiniteMagnitude,
                               y: CGFloat.greatestFiniteMagnitude)
    private var rightBottomPoint: CGPoint = .zero

    private var brushColor = DrawingViewModel.defaultBrushColor
    private var brushWidth: CGFloat = DrawingViewModel.defaultBrushWidth
    private var brushOpacity: CGFloat = DrawingViewModel.defaultBrushOpacity
    private var swiped = false

    @IBOutlet private weak var mainImageView: UIImageView!
    @IBOutlet private weak var tempImageView: UIImageView!

    private let viewModel = DrawingViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.title
        reset()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? DrawingBrushWidthViewController {
            controller.setCurrentWidth(brushWidth)
            controller.delegate = self
        } else if let controller = segue.destination as? DrawingBrushOpacityViewController {
            controller.setCurrectOpacity(brushOpacity)
            controller.delegate = self
        } else if let controller = segue.destination as? DrawingBrushColorViewController {
            controller.setCurrentColor(brushColor)
            controller.delegate = self
        }

        guard let popoverController = segue.destination.popoverPresentationController else {
            return
        }
        popoverController.sourceView = view
        popoverController.sourceRect = view.bounds
        popoverController.delegate = self
    }

    @IBAction private func reset() {
        mainImageView.image = nil

        lastPoint = .zero
        leftTopPoint = CGPoint(x: CGFloat.greatestFiniteMagnitude,
                                   y: CGFloat.greatestFiniteMagnitude)
        rightBottomPoint = .zero
    }

    @IBAction private func endDrawing() {
        if mainImageView.image == nil {
            alert(title: viewModel.errorTitle, message: viewModel.errorMessage)
            return
        }

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
                                                          name: viewModel.fileName,
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
        context.setStrokeColor(brushColor.cgColor)
        context.setBlendMode(.normal)

        context.strokePath()

        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = brushOpacity
        UIGraphicsEndImageContext()

        // Remember extremes of drawing
        adjustExtremes(for: fromPoint)
        adjustExtremes(for: toPoint)
    }

    private func adjustExtremes(for point: CGPoint) {
        if point.x < leftTopPoint.x {
            leftTopPoint.x = point.x - 2 * brushWidth
        } else if point.x > rightBottomPoint.x {
            rightBottomPoint.x = point.x + 2 * brushWidth
        }

        if point.y < leftTopPoint.y {
            leftTopPoint.y = point.y - 2 * brushWidth
        } else if point.y > rightBottomPoint.y {
            rightBottomPoint.y = point.y + 2 * brushWidth
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
        tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: tempImageView.frame.size.width, height: tempImageView.frame.size.height), blendMode: .normal, alpha: brushOpacity)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        tempImageView.image = nil
    }

}

extension DrawingViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

extension DrawingViewController: DrawingBrushWidthDelegate {
    func brushWidthChanged(width: CGFloat) {
        brushWidth = width
    }
}

extension DrawingViewController: DrawingBrushOpacityDelegate {
    func brushOpacityChanged(opacity: CGFloat) {
        brushOpacity = opacity
    }
}

extension DrawingViewController: DrawingBrushColorDelegate {
    func brushColorPicked(color: UIColor) {
        brushColor = color
        colorItem.tintColor = color
    }
}
