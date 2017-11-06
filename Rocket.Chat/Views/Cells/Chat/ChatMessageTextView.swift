//
//  ChatMessageTextView.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 2/16/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

protocol ChatMessageTextViewProtocol: class {
    func viewDidCollpaseChange(view: UIView)
    func openFileFromCell(attachment: Attachment)
}

final class ChatMessageTextView: UIView {

    static let defaultHeight = CGFloat(50)
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

    var viewModel: ChatMessageTextViewModel? {
        didSet {
            prepareView()
        }
    }

    private static let imageViewDefaultWidth = CGFloat(50)

    private lazy var tapGesture: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(viewDidTapped(_:)))
    }()

    private func prepareView() {
        addGestureIfNeeded()
        updateLeftBorder()
        updateLabels()
        updateImageView()
    }

    // MARK: Layout

    private func updateLeftBorder() {
        viewLeftBorder.backgroundColor = viewModel?.color
    }

    private func updateLabels() {
        labelTitle.text = viewModel?.title
        labelDescription.attributedText = NSMutableAttributedString(string: viewModel?.text ?? "").transformMarkdown()

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
            imageViewThumb.sd_setImage(with: thumbURL, completed: { _, error, _, _ in
                let width = error != nil ? 0 : ChatMessageTextView.imageViewDefaultWidth
                updateConstraint(width)
            })
        } else {
            updateConstraint(0)
        }
    }

    static func heightFor(collapsed: Bool, withText text: String?) -> CGFloat {
        if collapsed {
            return self.defaultHeight
        }

        let attributedString = NSMutableAttributedString(string: text ?? "").transformMarkdown()

        let fullWidth = UIScreen.main.bounds.size.width
        let height = attributedString.heightForView(withWidth: fullWidth - 80)
        return max(self.defaultHeight, height ?? 0) + 10
    }

    // MARK: Actions

    @objc func viewDidTapped(_ sender: Any) {
        viewModel?.toggleCollpase()
        delegate?.viewDidCollpaseChange(view: self)

        if let attachment = viewModel?.attachment {
            delegate?.openFileFromCell(attachment: attachment)
        }
    }

    private func addGestureIfNeeded() {
        let containsGesture = gestureRecognizers?.contains(tapGesture) ?? false
        if !containsGesture {
            addGestureRecognizer(tapGesture)
        }
    }
}
