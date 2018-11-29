//
//  HeaderCell.swift
//  Rocket.Chat
//
//  Created by Rafael Streit on 19/11/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController

final class HeaderCell: UICollectionViewCell, ChatCell, SizingCell {
    static let identifier = String(describing: HeaderCell.self)

    static let sizingCell: UICollectionViewCell & ChatCell = {
        guard let cell = HeaderCell.instantiateFromNib() else {
            return HeaderCell()
        }

        return cell
    }()

    lazy var avatarView: AvatarView = {
        let avatarView = AvatarView()

        avatarView.layer.cornerRadius = 4
        avatarView.layer.masksToBounds = true

        return avatarView
    }()

    @IBOutlet weak var avatarContainerView: UIView! {
        didSet {
            avatarContainerView.layer.cornerRadius = 4
            avatarView.frame = avatarContainerView.bounds
            avatarContainerView.addSubview(avatarView)
        }
    }

    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelDescription: UILabel!

    var messageWidth: CGFloat = 0
    var viewModel: AnyChatItem?

    func configure(completeRendering: Bool) {
        guard let viewModel = viewModel?.base as? HeaderChatItem else {
            return
        }

        labelName.text = viewModel.title
        labelDescription.text = viewModel.descriptionText
        avatarView.avatarURL = viewModel.avatarURL
    }

}
