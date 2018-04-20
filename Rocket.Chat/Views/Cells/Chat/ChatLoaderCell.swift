//
//  ChatLoaderCell.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 25/08/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

final class ChatLoaderCell: UICollectionViewCell {

    static let minimumHeight = CGFloat(50)
    static let identifier = "ChatLoaderCell"

    weak var loaderView: LoaderView?
    @IBOutlet weak var loaderViewContainer: UIView! {
        didSet {
            let loaderView = LoaderView(frame: CGRect(
                x: 0,
                y: 0,
                width: loaderViewContainer.frame.width,
                height: loaderViewContainer.frame.height
            ))

            loaderView.startAnimating()
            loaderViewContainer.addSubview(loaderView)
            self.loaderView = loaderView
        }
    }

}
