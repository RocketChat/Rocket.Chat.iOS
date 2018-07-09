//
//  ChatViewControllerBanner.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 7/5/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

extension ChatViewController {
    func showBanner(_ model: ChatBannerViewModel) {
        bannerView?.model = model
        bannerView?.isHidden = false
    }

    func hideBanner() {
        bannerView?.isHidden = true
    }

    func setupBanner() -> ChatBannerView? {
        guard let bannerView = ChatBannerView.instantiateFromNib() else {
            return nil
        }

        bannerView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(bannerView)

        bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        bannerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        bannerView.heightAnchor.constraint(equalToConstant: bannerView.frame.height).isActive = true

        return bannerView
    }
}
