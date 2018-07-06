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

        view.addSubview(bannerView)

        view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-0-[bannerView]-0-|",
                options: .alignAllLeft,
                metrics: nil,
                views: ["bannerView": bannerView]
            )
        )

        view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-0-[bannerView]",
                options: .alignAllLeft,
                metrics: nil,
                views: ["bannerView": bannerView]
            )
        )

        return bannerView
    }
}
