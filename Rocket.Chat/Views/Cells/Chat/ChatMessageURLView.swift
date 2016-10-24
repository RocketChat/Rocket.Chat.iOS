//
//  ChatMessageURLView.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/25/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

protocol ChatMessageURLViewProtocol {
    func openURLFromCell(url: MessageURL)
}

class ChatMessageURLView: BaseView {
    static let defaultHeight = CGFloat(50)
    fileprivate static let imageViewDefaultWidth = CGFloat(50)

    var delegate: ChatMessageURLViewProtocol?
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
    
    var tapGesture: UITapGestureRecognizer?
    
    fileprivate func updateMessageInformation() {
        if let gesture = tapGesture {
            self.removeGestureRecognizer(gesture)
        }
        
        tapGesture = UITapGestureRecognizer( target: self, action: #selector(viewDidTapped(_:)))
        addGestureRecognizer(tapGesture!)
        
        labelURLTitle.text = url.title
        labelURLDescription.text = url.textDescription
        
        if let imageURL = URL(string: url.imageURL ?? "") {
            imageViewURL.sd_setImage(with: imageURL, completed: { [unowned self] (image, error, cache, url) in
                let width = error != nil ? 0 : ChatMessageURLView.imageViewDefaultWidth
                self.imageViewURLWidthConstraint.constant = width
            })
        }
    }
    
    func viewDidTapped(_ sender: Any) {
        delegate?.openURLFromCell(url: url)
    }
}
