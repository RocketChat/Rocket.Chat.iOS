//
//  MessagesViewControllerBanner.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 10/2/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

extension MessagesViewController {
    private var bannerViewTag: Int {
        return "ChatBannerView".hashValue
    }

    var bannerView: ChatBannerView? {
        return view.viewWithTag(bannerViewTag) as? ChatBannerView
    }

    func showBanner(_ model: ChatBannerViewModel) {
        if bannerView == nil {
            setupBanner()
        }

        bannerView?.model = model
        bannerView?.isHidden = false
    }

    func hideBanner() {
        bannerView?.isHidden = true
    }

    func setupBanner() {
        guard bannerView == nil, let bannerView = ChatBannerView.instantiateFromNib() else {
            return
        }

        bannerView.tag = bannerViewTag
        bannerView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(bannerView)

        NSLayoutConstraint.activate([
            bannerView.topAnchor.constraint(equalTo: view.topAnchor),
            bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bannerView.widthAnchor.constraint(equalTo: view.widthAnchor),
            bannerView.heightAnchor.constraint(equalToConstant: bannerView.frame.height)
        ])
    }
}
