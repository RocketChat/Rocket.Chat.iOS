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

    @IBOutlet weak var backgroundImageView: FLAnimatedImageView!

    @IBOutlet weak var avatarImageView: FLAnimatedImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!

    @IBOutlet weak var tableView: UserDetailTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setTransparent()
    }
}
