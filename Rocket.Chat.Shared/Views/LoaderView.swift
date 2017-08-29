//
//  LoaderView.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 11/04/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

class LoaderView: UIView {

    enum Preset {
        case darkBlue
        case white
    }

    class func showLoader(for view: UIView, preset: Preset) {
        let loader = LoaderView(frame: CGRect(x: view.frame.width / 2 - 30, y: view.frame.height / 2 - 30, width: 60, height: 60))
        loader.preset = preset
        loader.alpha = 0
        view.addSubview(loader)
        loader.show(animated: true)
    }

    class func hideLoader(for view: UIView) {
        if let loader = LoaderView.loader(for: view) {
            loader.removeFromSuperviewOnHide = true
            loader.hide(animated: true)
        }
    }

    class func loader(for view: UIView) -> LoaderView? {
        return view.subviews.reversed().first { $0 is LoaderView } as? LoaderView
    }

    var preset: Preset = .darkBlue {
        didSet {
            switch preset {
            case .darkBlue:
                fillColor = UIColor.RCDarkBlue().cgColor
            case .white:
                layer.cornerRadius = 6
                backgroundColor = UIColor.lightGray
                fillColor = UIColor.white.cgColor
            }
        }
    }
    var fillColor: CGColor = UIColor.RCDarkBlue().cgColor
    var removeFromSuperviewOnHide = true
    var isAnimating = false
    override var isHidden: Bool {
        didSet {
            if isHidden && removeFromSuperviewOnHide {
                removeFromSuperview()
            }
        }
    }

    public final func startAnimating() {
        isHidden = false
        isAnimating = true
        layer.speed = 1

        layer.sublayers = nil
        setupLayersAndAnimation(in: self.layer, size: CGSize(width: 42, height: 42))
    }

    public final func stopAnimating() {
        isHidden = true
        isAnimating = false
        layer.sublayers?.removeAll()
    }

    func show(animated: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.alpha = 0.56
            self.startAnimating()
        }
    }

    func hide(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.2) {
                self.alpha = 0
                self.isHidden = true
            }
        } else {
            self.isHidden = true
        }
    }

    func setupLayersAndAnimation(in layer: CALayer, size: CGSize) {
        let circleSpacing: CGFloat = 4
        let circleSize: CGFloat = 10
        let circleRadius = circleSize / 2
        let x: CGFloat = (layer.bounds.size.width - size.width) / 2
        let y: CGFloat = (layer.bounds.size.height - circleSize) / 2
        let duration: CFTimeInterval = 1.4
        let beginTime = CACurrentMediaTime()
        let beginTimes: [CFTimeInterval] = [0, 0.16, 0.32]
        let timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")

        // Animation
        animation.timingFunctions = [timingFunction, timingFunction]
        animation.values = [0, 1, 0]
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false

        // Draw circles
        for i in 0 ..< 3 {
            let circleLayer: CAShapeLayer = CAShapeLayer()
            let path: UIBezierPath = UIBezierPath()

            path.addArc(
                withCenter: CGPoint(x: circleRadius, y: circleRadius),
                radius: circleRadius,
                startAngle: 0,
                endAngle: CGFloat(2 * Double.pi),
                clockwise: false
            )

            circleLayer.fillColor = fillColor
            circleLayer.backgroundColor = nil
            circleLayer.path = path.cgPath
            circleLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)

            let circle = circleLayer as CALayer
            let frame = CGRect(
                x: x + circleSize * CGFloat(i) + circleSpacing * CGFloat(i),
                y: y,
                width: circleSize,
                height: circleSize
            )

            animation.beginTime = beginTime + beginTimes[i]
            circle.frame = frame
            circle.add(animation, forKey: "animation")
            layer.addSublayer(circle)
        }
    }

}
