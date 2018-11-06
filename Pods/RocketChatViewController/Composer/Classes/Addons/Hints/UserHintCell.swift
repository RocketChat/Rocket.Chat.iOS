//
//  UserHintCell.swift
//  RocketChatViewController Example
//
//  Created by Matheus Cardoso on 9/12/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

open class UserHintCell<AvatarView: UIView>: UITableViewCell {
    /*
     The user's avatar image view
     */
    public let avatarView: AvatarView = tap(AvatarView()) {
        $0.translatesAutoresizingMaskIntoConstraints = false

        $0.layer.cornerRadius = Consts.avatarCornerRadius
        $0.clipsToBounds = true

        NSLayoutConstraint.activate([
            $0.widthAnchor.constraint(equalToConstant: Consts.avatarWidth),
            $0.heightAnchor.constraint(equalToConstant: Consts.avatarHeight)
        ])
    }

    /*
     The user's name label
     */
    public let nameLabel: UILabel = tap(UILabel()) {
        $0.translatesAutoresizingMaskIntoConstraints = false

        $0.font = .preferredFont(forTextStyle: .body)
        $0.adjustsFontForContentSizeCategory = true
    }

    /*
     The user's username label
     */
    public let usernameLabel: UILabel = tap(UILabel()) {
        $0.translatesAutoresizingMaskIntoConstraints = false

        $0.font = .preferredFont(forTextStyle: .footnote)
        $0.adjustsFontForContentSizeCategory = true

        $0.textColor = Consts.usernameColor
    }

    open override var intrinsicContentSize: CGSize {
        let height = layoutMargins.top +
            layoutMargins.bottom +
            nameLabel.intrinsicContentSize.height +
            usernameLabel.intrinsicContentSize.height

        return CGSize(width: super.intrinsicContentSize.width, height: height)
    }

    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    /**
     Shared initialization procedures.
     */
    private func commonInit() {
        addSubviews()
        setupConstraints()
    }

    /**
     Adds buttons and other UI elements as subviews.
     */
    private func addSubviews() {
        addSubview(avatarView)
        addSubview(nameLabel)
        addSubview(usernameLabel)
    }

    /**
     Sets up constraints between the UI elements in the composer.
     */
    private func setupConstraints() {
        NSLayoutConstraint.activate([

            // avatarView

            avatarView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: layoutMargins.left),
            avatarView.centerYAnchor.constraint(equalTo: centerYAnchor),

            // nameLabel

            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: Consts.nameLeading),
            nameLabel.bottomAnchor.constraint(equalTo: centerYAnchor, constant: Consts.nameBottom),

            // usernameLabel

            usernameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: Consts.nameLeading),
            usernameLabel.topAnchor.constraint(equalTo: centerYAnchor, constant: Consts.usernameTop)
        ])
    }
}

// MARK: Consts

/**
 Constants for sizes and margins in the cell view.
 */
private struct Consts {
    static var intrinsicHeight: CGFloat = 54

    static var avatarWidth: CGFloat = 30
    static var avatarHeight: CGFloat = 30
    static var avatarLeading: CGFloat = 15
    static var avatarCornerRadius: CGFloat = 4

    static var nameLeading: CGFloat = 15
    static var nameBottom: CGFloat = 0

    static var usernameLeading: CGFloat = 15
    static var usernameTop: CGFloat = 0
    static var usernameColor: UIColor = #colorLiteral(red: 0.6196078431, green: 0.6352941176, blue: 0.6588235294, alpha: 1)
}
