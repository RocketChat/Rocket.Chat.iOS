//
//  SequentialMessageCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 28/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController

final class SequentialMessageCell: BaseMessageCell, BaseMessageCellProtocol, SizingCell {
    static let identifier = String(describing: SequentialMessageCell.self)

    static let sizingCell: UICollectionViewCell & ChatCell = {
        guard let cell = SequentialMessageCell.instantiateFromNib() else {
            return SequentialMessageCell()
        }

        return cell
    }()

    @IBOutlet weak var text: RCTextView!
    @IBOutlet weak var readReceiptButton: UIButton!

    @IBOutlet weak var textHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var textTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var readReceiptWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var readReceiptTrailingConstraint: NSLayoutConstraint!
    var textWidth: CGFloat {
        return
            adjustedHorizontalInsets -
            textLeadingConstraint.constant -
            textTrailingConstraint.constant -
            readReceiptWidthConstraint.constant -
            readReceiptTrailingConstraint.constant
    }

    weak var longPressGesture: UILongPressGestureRecognizer?
    weak var delegate: ChatMessageCellProtocol? {
        didSet {
            text.delegate = delegate
        }
    }

    var initialTextHeightConstant: CGFloat = 0

    override func awakeFromNib() {
        super.awakeFromNib()

        initialTextHeightConstant = textHeightConstraint.constant

        insertGesturesIfNeeded()
    }

    override func configure() {
        configure(readReceipt: readReceiptButton)
        updateText()
    }

    func updateText() {
        guard
            let viewModel = viewModel?.base as? SequentialMessageChatItem,
            let managedObject = viewModel.message.managedObject
        else {
            return
        }

        if let message = MessageTextCacheManager.shared.message(for: managedObject, with: theme) {
            if viewModel.message.temporary {
                message.setFontColor(MessageTextFontAttributes.systemFontColor(for: theme))
            } else if viewModel.message.failed {
                message.setFontColor(MessageTextFontAttributes.failedFontColor(for: theme))
            }

            text.message = message

            let maxSize = CGSize(
                width: textWidth,
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
        guard
            let viewModel = viewModel?.base as? BasicMessageChatItem,
            let managedObject = viewModel.message.managedObject
        else {
            return
        }

        delegate?.handleLongPressMessageCell(managedObject, view: contentView, recognizer: recognizer)
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
        updateText()
    }

}
