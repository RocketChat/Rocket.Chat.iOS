//
//  UIViewControllerDimming.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 11/23/18.
//

import UIKit

let kDimViewAlpha: CGFloat = 0.6
let kDimViewAnimationDuration = 0.25

class DimView: UIView { }

extension UIViewController {
    var dimViewTag: Int {
        return "Dim_View".hashValue
    }

    var dimView: DimView {
        if let res = view.viewWithTag(dimViewTag) as? DimView {
            res.frame = view.bounds
            return res
        } else {
            let dimView = DimView(frame: view.bounds)
            dimView.tag = dimViewTag
            dimView.backgroundColor = .black
            dimView.alpha = kDimViewAlpha

            view.addSubview(dimView)
            return dimView
        }
    }

    func startDimming() {
        view.bringSubviewToFront(dimView)
        dimView.isHidden = false

        UIView.animate(withDuration: kDimViewAnimationDuration) { [dimView] in
            dimView.alpha = kDimViewAlpha
        }
    }

    func stopDimming() {

        UIView.animate(withDuration: kDimViewAnimationDuration, animations: { [dimView] in
            dimView.alpha = 0
        }, completion: { [dimView] _ in
            dimView.isHidden = true
        })
    }
}
