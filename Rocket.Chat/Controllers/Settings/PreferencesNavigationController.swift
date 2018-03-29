//
//  PreferencesNavigationController.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 1/11/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class PreferencesNavigationController: BaseNavigationController {

    private var mediumScreenFrame: CGRect = .zero
    private var fullScreenFrame: CGRect = .zero
    private var frame: CGRect?

    public var fullScreen: Bool = false {
        didSet {
            guard UIDevice.current.userInterfaceIdiom == .pad else { return }

            frame = fullScreen ? fullScreenFrame : mediumScreenFrame
            viewWillLayoutSubviews()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mediumScreenFrame = CGRect(origin: .zero, size: CGSize(width: 540, height: 620))

        if let frame = UIApplication.shared.keyWindow?.frame {
            fullScreenFrame = frame
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        guard UIDevice.current.userInterfaceIdiom == .pad else { return }

        if let frame = frame {
            self.view.superview?.bounds = frame
        }
    }

}
