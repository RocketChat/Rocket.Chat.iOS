//
//  ChatViewController+RegisterCells.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 6/2/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

extension ChatViewController {
    func registerCells() {
        collectionView?.register(UINib(
            nibName: "ChatMessageCell",
            bundle: RocketChat.resourceBundle
        ), forCellWithReuseIdentifier: ChatMessageCell.identifier)

        collectionView?.register(UINib(
            nibName: "ChatMessageDaySeparator",
            bundle: RocketChat.resourceBundle
        ), forCellWithReuseIdentifier: ChatMessageDaySeparator.identifier)

        autoCompletionView.register(UINib(
            nibName: "AutocompleteCell",
            bundle: RocketChat.resourceBundle
        ), forCellReuseIdentifier: AutocompleteCell.identifier)
    }
}
