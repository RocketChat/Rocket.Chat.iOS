//
//  UserDetailViewController.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 6/26/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import FLAnimatedImage

class UserDetailViewController: BaseViewController, StoryboardInitializable {
    static var storyboardName: String = "UserDetail"

    @IBOutlet weak var backgroundImageView: FLAnimatedImageView?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.setTransparent()
    }
}

// MARK: Table Header View

extension UserDetailViewController {
    private var tableHeaderViewHeight: Int {
        return 308
    }

    /*func updateTableHeaderView() {
        var posterRect = CGRect(
            x: 0, y: -tableHeaderViewHeight,
            width: tableView.bounds.width, height: posterViewHeight
        )

        if tableView.contentOffset.y < -posterViewHeight {
            posterRect.origin.y = tableView.contentOffset.y
            posterRect.size.height = -tableView.contentOffset.y
        }

        posterView.frame = posterRect
    }*/
}
