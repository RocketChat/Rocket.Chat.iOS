//
//  MessagesViewControllerEmptyState.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 11/12/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

extension MessagesViewController {
    func updateEmptyState() {
        if subscription == nil && threadIdentifier == nil {
            title = ""
            composerView.isHidden = true

            chatTitleView?.removeFromSuperview()
            emptyStateImageView?.removeFromSuperview()

            guard let theme = view.theme else { return }
            let themeName = ThemeManager.themes.first { $0.theme == theme }?.title

            let imageView = UIImageView(image: UIImage(named: "Empty State \(themeName ?? "light")"))
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            view.addSubview(imageView)

            emptyStateImageView = imageView

            updateEmptyStateFrame()
        } else {
            emptyStateImageView?.removeFromSuperview()
        }
    }

    func updateEmptyStateFrame() {
        emptyStateImageView?.frame = view.bounds
    }
}
