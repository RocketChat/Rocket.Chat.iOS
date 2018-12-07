//
//  SequentialMessageCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 28/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController

final class SequentialMessageCell: BaseMessageCell, SizingCell {
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
            messageWidth -
            textLeadingConstraint.constant -
            textTrailingConstraint.constant -
            readReceiptWidthConstraint.constant -
            readReceiptTrailingConstraint.constant -
            layoutMargins.left -
            layoutMargins.right
    }

    override var delegate: ChatMessageCellProtocol? {
        didSet {
            text.delegate = delegate
        }
    }

    var initialTextHeightConstant: CGFloat = 0

    override func awakeFromNib() {
        super.awakeFromNib()

        initialTextHeightConstant = textHeightConstraint.constant

        insertGesturesIfNeeded(with: nil)
    }

    override func configure(completeRendering: Bool) {
        configure(readReceipt: readReceiptButton)
        updateText()
    }

    func updateText() {
        guard
            let viewModel = viewModel?.base as? SequentialMessageChatItem,
            let message = viewModel.message
        else {
            return
        }

        if let messageText = MessageTextCacheManager.shared.message(for: message, with: theme) {
            if message.temporary {
                messageText.setFontColor(MessageTextFontAttributes.systemFontColor(for: theme))
            } else if message.failed {
                messageText.setFontColor(MessageTextFontAttributes.failedFontColor(for: theme))
            }

            text.message = messageText

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
}

extension SequentialMessageCell {

    override func applyTheme() {
        super.applyTheme()
        updateText()
    }

}
