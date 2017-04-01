//
//  ChatMessageTextView.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 2/16/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import RealmSwift

protocol ChatMessageTextViewProtocol: class {
    func viewDidCollpaseChange(view: UIView)
}

final class ChatMessageTextView: UIView {
    static let defaultHeight = CGFloat(50)
    fileprivate static let imageViewDefaultWidth = CGFloat(50)

    weak var delegate: ChatMessageTextViewProtocol?

    @IBOutlet weak var imageViewThumbWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewThumb: UIImageView! {
        didSet {
            imageViewThumb.layer.masksToBounds = true
        }
    }

    @IBOutlet weak var viewLeftBorder: UIView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDescription: UILabel!

    var attachment: Attachment? {
        didSet {
            updateMessageInformation()
        }
    }

    private lazy var tapGesture: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(viewDidTapped(_:)))
    }()

    fileprivate func updateMessageInformation() {
        guard let attachment = self.attachment else { return }

        let containsGesture = gestureRecognizers?.contains(tapGesture) ?? false
        if !containsGesture {
            addGestureRecognizer(tapGesture)
        }

        if attachment.color != nil {
            viewLeftBorder.backgroundColor = UIColor(hex: attachment.color)
        } else {
            viewLeftBorder.backgroundColor = .lightGray
        }

        labelTitle.text = attachment.title
        labelDescription.text = attachment.text

        if let imageURL = URL(string: attachment.thumbURL ?? "") {
            imageViewThumb.sd_setImage(with: imageURL, completed: { [weak self] _, error, _, _ in
                let width = error != nil ? 0 : ChatMessageTextView.imageViewDefaultWidth
                self?.imageViewThumbWidthConstraint.constant = width
                self?.layoutSubviews()
            })
        } else {
            imageViewThumbWidthConstraint.constant = 0
            layoutSubviews()
        }
    }

    static func heightFor(_ attachment: Attachment) -> CGFloat {
        if attachment.collapsed {
            return self.defaultHeight
        }

        let fullWidth = UIScreen.main.bounds.size.width
        return max(self.defaultHeight, UILabel.heightForView(
            attachment.text ?? "",
            font: UIFont.systemFont(ofSize: 14),
            width: fullWidth - 60
        ) + 20)
    }

    func viewDidTapped(_ sender: Any) {
        guard let attachment = self.attachment else { return }

        Realm.execute { (_) in
            attachment.collapsed = !attachment.collapsed
        }

        delegate?.viewDidCollpaseChange(view: self)
    }
}
