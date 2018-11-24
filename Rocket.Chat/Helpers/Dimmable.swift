//
//  UIViewControllerDimming.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 11/23/18.
//

import UIKit

class DimView: UIView { }
protocol Dimmable { }

extension Dimmable where Self: UIViewController {
    var dimViewTag: Int {
        return "Dim_View".hashValue
    }

    var dimView: DimView {
        if let res = view.viewWithTag(dimViewTag) as? DimView {
            return res
        } else {
            let dimView = DimView(frame: view.frame)
            dimView.tag = dimViewTag
            dimView.backgroundColor = .black
            dimView.alpha = 0.6

            view.addSubview(dimView)
            return dimView
        }
    }

    func startDimming() {
        view.bringSubviewToFront(dimView)
        dimView.isHidden = false
    }

    func stopDimming() {
        dimView.isHidden = true
    }
}
