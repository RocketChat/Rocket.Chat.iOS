//
//  MemberCell.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/19/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

struct MemberCellData {
    let member: API.User

    var nameText: String {
        return "\(member.name) (UTC \(member.utcOffset))"
    }

    var statusColor: UIColor {
        switch member.status {
        case "online":
            return .green
        case "away":
            return .yellow
        case "busy":
            return .red
        case "offline":
            return .black
        default:
            return .white
        }
    }
}

class MemberCell: UITableViewCell {
    static let identifier = "MemberCell"

    @IBOutlet weak var statusView: UIView! {
        didSet {
            statusView.layer.cornerRadius = statusView.layer.frame.width/2
        }
    }

    @IBOutlet weak var avatarViewContainer: UIView! {
        didSet {
            if let avatarView = AvatarView.instantiateFromNib() {
                avatarView.frame = avatarViewContainer.bounds
                avatarViewContainer.addSubview(avatarView)
                self.avatarView = avatarView
            }
        }
    }

    weak var avatarView: AvatarView! {
        didSet {
            avatarView.layer.cornerRadius = 4
            avatarView.layer.masksToBounds = true
        }
    }

    @IBOutlet weak var nameLabel: UILabel!

    var data: MemberCellData? = nil {
        didSet {
            statusView.backgroundColor = data?.statusColor
            nameLabel.text = data?.nameText
            avatarView.username = data?.member.username
        }
    }

    override func awakeFromNib() {
        avatarViewContainer.layer.masksToBounds = true
        avatarViewContainer.layer.cornerRadius = 5

        if let avatarView = AvatarView.instantiateFromNib() {
            avatarView.frame = CGRect(
                x: 0,
                y: 0,
                width: avatarViewContainer.frame.width,
                height: avatarViewContainer.frame.height
            )

            avatarViewContainer.addSubview(avatarView)
            self.avatarView = avatarView
        }
    }
}
