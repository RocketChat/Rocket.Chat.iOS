//
//  LoaderTitleView.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 11/06/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

enum LoaderTitleViewState {
    case connecting
    case waitingNetwork
}

final class LoaderTitleView: UIView {

    var status: LoaderTitleViewState = .connecting {
        didSet {
            updateStatusLabel()
        }
    }

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var labelMessage: UILabel! {
        didSet {
            updateStatusLabel()
        }
    }

    fileprivate func updateStatusLabel() {
        switch status {
        case .connecting:
            labelMessage?.text = localized("connection.connecting.banner.message")
        case .waitingNetwork:
            labelMessage?.text = localized("connection.waiting_for_network.banner.message")
        }
    }

    override var intrinsicContentSize: CGSize {
        if #available(iOS 11.0, *) {
            return UILayoutFittingExpandedSize
        }

        return UILayoutFittingCompressedSize
    }

}
