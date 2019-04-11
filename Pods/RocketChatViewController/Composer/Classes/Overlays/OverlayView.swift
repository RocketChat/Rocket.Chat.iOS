//
//  OverlayView.swift
//  RocketChatViewController
//
//  Created by Matheus Cardoso on 09/01/2019.
//

import UIKit

public class OverlayView: UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
