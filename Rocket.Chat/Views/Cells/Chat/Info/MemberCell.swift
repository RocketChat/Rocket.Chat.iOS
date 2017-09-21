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

    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    var data: MemberCellData? = nil {
        didSet {
            statusView.backgroundColor = data?.statusColor
            nameLabel.text = data?.nameText
        }
    }

    override func awakeFromNib() {

    }
}
