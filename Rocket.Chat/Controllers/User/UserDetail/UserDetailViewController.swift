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

    @IBOutlet weak var tableView: UserDetailTableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }

    var model: UserDetailViewModel = .emptyState {
        didSet {
            updateForModel()
        }
    }

    func updateForModel() {
        tableView?.reloadData()
        nameLabel?.text = model.name
        usernameLabel?.text = model.username
        if let url = model.avatarUrl, let avatar = avatarImageView, let background = backgroundImageView {
            ImageManager.loadImage(with: url, into: avatar)
            ImageManager.loadImage(with: url, into: background)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateForModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        UIView.animate(withDuration: 1.0) {
            self.navigationController?.navigationBar.setTransparent()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        UIView.animate(withDuration: 1.0) {
            self.navigationController?.navigationBar.setNonTransparent()
        }
    }
}

extension UserDetailViewController {
    func withModel(_ model: UserDetailViewModel) -> UserDetailViewController {
        self.model = model
        return self
    }
}

extension UserDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return model.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.numberOfRowsForSection(section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserDetailFieldCell") as? UserDetailFieldCell else {
            fatalError("Could not dequeue reusable cell 'UserDetailFieldCell'")
        }

        cell.model = model.cellForRowAtIndexPath(indexPath)

        return cell
    }
}

extension UserDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 13
    }
}
