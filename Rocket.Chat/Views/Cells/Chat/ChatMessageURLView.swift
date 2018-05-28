//
//  ChatMessageURLView.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/25/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

protocol ChatMessageURLViewProtocol: class {
    func openURLFromCell(url: MessageURL)
}

final class ChatMessageURLView: UIView {
    static let defaultHeight = CGFloat(50)
    fileprivate static let imageViewDefaultWidth = CGFloat(50)

    weak var delegate: ChatMessageURLViewProtocol?
    var url: MessageURL! {
        didSet {
            updateMessageInformation()
        }
    }

    @IBOutlet weak var imageViewURLWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewURL: UIImageView! {
        didSet {
            imageViewURL.layer.masksToBounds = true
        }
    }

    @IBOutlet weak var labelURLTitle: UILabel!
    @IBOutlet weak var labelURLDescription: UILabel!

    private lazy var tapGesture: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(viewDidTapped(_:)))
    }()

    fileprivate func updateMessageInformation() {
        let containsGesture = gestureRecognizers?.contains(tapGesture) ?? false
        if !containsGesture {
            addGestureRecognizer(tapGesture)
        }

        labelURLTitle.text = url.title
        labelURLDescription.text = url.textDescription

        if let imageURL = URL(string: url.imageURL ?? "") {
            ImageManager.loadImage(with: imageURL, into: imageViewURL) { [weak self] _, error in
                let width = error != nil ? 0 : ChatMessageURLView.imageViewDefaultWidth
                self?.imageViewURLWidthConstraint.constant = width
                self?.layoutSubviews()
            }
        } else {
            imageViewURLWidthConstraint.constant = 0
            layoutSubviews()
        }
    }

    @objc func viewDidTapped(_ sender: Any) {
        delegate?.openURLFromCell(url: url)
    }
}
