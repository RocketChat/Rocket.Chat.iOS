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
        return "\(member.displayName()) \(utcText)"
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

final class MemberCell: UITableViewCell {
    static let identifier = "MemberCell"

    @IBOutlet weak var statusView: UIView! {
        didSet {
            statusView.layer.cornerRadius = statusView.layer.frame.width / 2
        }
    }

    @IBOutlet weak var statusViewWidthConstraint: NSLayoutConstraint! {
        didSet {
            statusViewWidthConstraint?.constant = hideStatus ? 0 : 8
        }
    }

    var hideStatus: Bool = false {
        didSet {
            statusViewWidthConstraint?.constant = hideStatus ? 0 : 8
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

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

// MARK: ReactorCell

extension MemberCell: ReactorPresenter {
    var reactor: String {
        set {
            guard !newValue.isEmpty else { return }

            if let user = User.find(username: newValue) {
                data = MemberCellData(member: user)
                return
            }

            User.fetch(by: .username(newValue), completion: { user in
                guard let user = user else { return }
                self.data = MemberCellData(member: user)
            })
        }

        get {
            return data?.member.username ?? ""
        }
    }
}
