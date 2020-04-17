//
//  ChatMessageTextView.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 2/16/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController

protocol ChatMessageTextViewProtocol: class {
    func viewDidCollapseChange(viewModel: AnyChatItem)
    func openFileFromCell(attachment: UnmanagedAttachment)
}

final class ChatMessageTextView: UIView {

    static let defaultHeight = CGFloat(52)
    static let defaultTitleHeight = CGFloat(17)

    @IBOutlet weak var imageViewThumbWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewThumb: UIImageView! {
        didSet {
            imageViewThumb.layer.masksToBounds = true
        }
    }

    @IBOutlet weak var viewLeftBorder: UIView!
    @IBOutlet weak var labelTitleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDescription: UILabel!

    weak var delegate: ChatMessageTextViewProtocol?

    var viewModel: ChatMessageTextViewModelProtocol? {
        didSet {
            prepareView()
        }
    }

    private static let imageViewDefaultWidth = CGFloat(50)

    private lazy var tapGesture: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(viewDidTapped(_:)))
    }()

    func prepareView() {
        addGestureIfNeeded()
        updateLabels()
        updateImageView()
        applyTheme()
    }

    // MARK: Layout

    private func updateLabels() {
        labelTitle.text = viewModel?.title
        labelDescription.attributedText = NSMutableAttributedString(string: viewModel?.text ?? "").transformMarkdown(with: self.theme)

        if viewModel?.title.count == 0 {
            labelTitleHeightConstraint.constant = 0
        } else {
            labelTitleHeightConstraint.constant = ChatMessageTextView.defaultTitleHeight
        }
    }

    private func updateImageView() {
        let updateConstraint = { [weak self] (constant: CGFloat) in
            self?.imageViewThumbWidthConstraint.constant = constant
            self?.layoutSubviews()
        }

        if let thumbURL = viewModel?.thumbURL {
            ImageManager.loadImage(with: thumbURL, into: imageViewThumb) { result in
                if case let .success(resp) = result {
                    updateConstraint(ChatMessageTextView.imageViewDefaultWidth)
                } else {
                    updateConstraint(0)
                }
            }
        } else {
            updateConstraint(0)
        }
    }

    static func heightFor(with availableWidth: CGFloat, collapsed: Bool, text: String?, isFile: Bool = false) -> CGFloat {
        guard !isFile else {
            return defaultHeight
        }

        let width = availableWidth - 73
        var textHeight: CGFloat = 1

        if let text = text, text.count > 0 {
            let attributedString = NSMutableAttributedString(string: text)
            attributedString.setFont(.systemFont(ofSize: 13.0))
            textHeight += (attributedString.transformMarkdown().heightForView(withWidth: width) ?? 0)
        }

        let totalHeight = defaultTitleHeight + textHeight

        return collapsed ? min(totalHeight, defaultHeight) : totalHeight
    }

    // MARK: Actions

    @objc func viewDidTapped(_ sender: Any) {
        if viewModel?.isFile == false {
            viewModel?.toggleCollapse()
//            delegate?.viewDidCollapseChange(view: self)
        }

        if let attachment = viewModel?.attachment {
            if attachment.titleLinkDownload, let unmanaged = UnmanagedAttachment(attachment) {
                delegate?.openFileFromCell(attachment: unmanaged)
            }
        }
    }

    private func addGestureIfNeeded() {
        let containsGesture = gestureRecognizers?.contains(tapGesture) ?? false
        if !containsGesture {
            addGestureRecognizer(tapGesture)
        }
    }
}

// MARK: Themeable

extension ChatMessageTextView {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }
        viewLeftBorder.backgroundColor = viewModel?.color ?? theme.auxiliaryText
        labelDescription.textColor = theme.auxiliaryText
        labelTitle.textColor = theme.controlText
    }
}
