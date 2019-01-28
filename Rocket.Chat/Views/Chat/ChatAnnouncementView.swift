//
//  ChatAnnouncementView.swift
//  Rocket.Chat
//
//  Created by Bryan Lew on 24/1/19.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import UIKit

final class ChatAnnouncementView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var subscription: UnmanagedSubscription? {
        didSet {
            guard let subscription = subscription else { return }
            guard let announcement = subscription.roomAnnouncement else { return }
            let attributedString = NSAttributedString(string: announcement)
            announcementLabel.attributedText = MarkdownManager.shared.transformAttributedString(attributedString)
        }
    }

    let announcementLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    fileprivate func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(announcementLabel)
        NSLayoutConstraint.activate([
            announcementLabel.topAnchor.constraint(equalTo: topAnchor),
            announcementLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            announcementLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 12),
            announcementLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -12)
        ])
    }
}

// MARK: Themeable

extension ChatAnnouncementView {

    override func applyTheme() {
        super.applyTheme()
        backgroundColor = theme?.bannerBackground
        announcementLabel.textColor = theme?.auxiliaryText
    }

}
