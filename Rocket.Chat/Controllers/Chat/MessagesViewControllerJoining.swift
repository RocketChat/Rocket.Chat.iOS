//
//  MessagesViewControllerJoining.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 11/14/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import RealmSwift

extension MessagesViewController {
    private func showChatPreviewModeView() {
        chatPreviewModeView?.removeFromSuperview()

        if let previewView = ChatPreviewModeView.instantiateFromNib() {
            previewView.delegate = self
            previewView.subscription = subscription
            previewView.translatesAutoresizingMaskIntoConstraints = false

            view.addSubview(previewView)

            NSLayoutConstraint.activate([
                previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])

            collectionView?.bottomAnchor.constraint(equalTo: previewView.topAnchor).isActive = true

            chatPreviewModeView = previewView
            updateChatPreviewModeViewConstraints()

            previewView.applyTheme()
        }
    }

    func updateJoinedView() {
        guard let subscription = subscription else { return }

        if subscription.isJoined() {
            composerView.isHidden = false
            chatPreviewModeView?.removeFromSuperview()
        } else {
            composerView.isHidden = true
            showChatPreviewModeView()
        }
    }

    private func updateChatPreviewModeViewConstraints() {
        chatPreviewModeView?.bottomInset = view.safeAreaInsets.bottom
    }
}

extension MessagesViewController: ChatPreviewModeViewProtocol {
    func userDidJoinedSubscription() {
        guard let auth = AuthManager.isAuthenticated() else { return }
        guard let subscription = self.subscription else { return }

        Realm.executeOnMainThread({ realm in
            subscription.auth = auth
            realm.add(subscription, update: true)
        })

        self.subscription = subscription
        updateJoinedView()
    }
}
