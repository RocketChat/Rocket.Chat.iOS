//
//  MemberCell.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/19/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

struct MemberCellData {
    let member: User

    var nameText: String {
        let utcText = member.utcOffset != nil ? "(UTC \(member.utcOffset ?? 0))" : ""
        return "\(member.name ?? "") \(utcText)"
    }

    var statusColor: UIColor {
        switch member.status {
        case .online:
            return .RCOnline()
        case .away:
            return .RCAway()
        case .busy:
            return .RCBusy()
        case .offline:
            return .RCInvisible()
        }
    }
}

class MemberCell: UITableViewCell {
    static let identifier = "MemberCell"

    @IBOutlet weak var statusView: UIView! {
        didSet {
            statusView.layer.cornerRadius = statusView.layer.frame.width / 2
        }
    }

    @IBOutlet weak var avatarViewContainer: UIView! {
        didSet {
            avatarViewContainer.layer.masksToBounds = true
            avatarViewContainer.layer.cornerRadius = 5

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
            avatarView.user = data?.member
        }
    }

}
