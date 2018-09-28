//
//  SequentialMessageCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 28/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController

final class SequentialMessageCell: UICollectionViewCell, ChatCell, SizingCell {
    static let identifier = String(describing: SequentialMessageCell.self)

    static let sizingCell: UICollectionViewCell & ChatCell = {
        guard let cell = SequentialMessageCell.instantiateFromNib() else {
            return SequentialMessageCell()
        }

        return cell
    }()

    @IBOutlet weak var text: RCTextView!

    @IBOutlet weak var textHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var textTrailingConstraint: NSLayoutConstraint!
    var textHorizontalMargins: CGFloat {
        return textLeadingConstraint.constant +
            textTrailingConstraint.constant
    }

    weak var longPressGesture: UILongPressGestureRecognizer?
    weak var delegate: ChatMessageCellProtocol? {
        didSet {
            text.delegate = delegate
        }
    }

    var viewModel: AnyChatItem?
    var initialTextHeightConstant: CGFloat = 0
    var contentViewWidthConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()

        initialTextHeightConstant = textHeightConstraint.constant

        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentViewWidthConstraint = contentView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
        contentViewWidthConstraint.isActive = true

        insertGesturesIfNeeded()
    }

    func configure() {
        updateText()
    }

    func updateText(force: Bool = false) {
        guard let viewModel = viewModel?.base as? SequentialMessageChatItem else {
            return
        }

        if let message = force ? MessageTextCacheManager.shared.update(for: viewModel.message.managedObject, with: theme) : MessageTextCacheManager.shared.message(for: viewModel.message.managedObject, with: theme) {
            contentViewWidthConstraint.constant = UIScreen.main.bounds.width
            if viewModel.message.temporary {
                message.setFontColor(MessageTextFontAttributes.systemFontColor(for: theme))
            } else if viewModel.message.failed {
                message.setFontColor(MessageTextFontAttributes.failedFontColor(for: theme))
            }

            text.message = message

            // FA NOTE: Using UIScreen.main bounds is fine because we are not using
            // section insets, but in the future we can create a mechanism that
            // discounts the UICollectionView's section insets from the main screen's bounds
            let screenWidth = UIScreen.main.bounds.width
            let maxSize = CGSize(
                width: screenWidth - textHorizontalMargins,
                height: .greatestFiniteMagnitude
            )

            textHeightConstraint.constant = text.textView.sizeThatFits(
                maxSize
            ).height
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        text.message = nil
        textHeightConstraint.constant = initialTextHeightConstant
    }

    func insertGesturesIfNeeded() {
        if longPressGesture == nil {
            let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressMessageCell(recognizer:)))
            gesture.minimumPressDuration = 0.325
            gesture.delegate = self
            addGestureRecognizer(gesture)

            longPressGesture = gesture
        }
    }

    @objc func handleLongPressMessageCell(recognizer: UIGestureRecognizer) {
        guard let viewModel = viewModel?.base as? BasicMessageChatItem else {
            return
        }

        delegate?.handleLongPressMessageCell(viewModel.message.managedObject, view: contentView, recognizer: recognizer)
    }
}

extension SequentialMessageCell: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

extension SequentialMessageCell {
    override func applyTheme() {
        super.applyTheme()
        updateText(force: true)
    }
}
