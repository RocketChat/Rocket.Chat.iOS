//
//  ChatBannerViewModel.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 7/5/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

struct ChatBannerViewModel {
    let text: String
    let actionText: String?
    let imageName: String?
    let showCloseButton: Bool
    let progress: Float
}

// MARK: Empty State

extension ChatBannerViewModel {
    static var emptyState: ChatBannerViewModel {
        return ChatBannerViewModel(
            text: "Uploading layout_webapp.jpg",
            actionText: "Try again",
            imageName: "Message_Upload_Image",
            showCloseButton: true,
            progress: 0
        )
    }
}

// MARK: Upload

extension ChatBannerViewModel {
    static func forUploadingFile(named name: String, type: String) -> ChatBannerViewModel {
        return ChatBannerViewModel(
            text: "Uploading \(name)",
            actionText: nil,
            imageName: type.contains("image") || type.contains("video") ? "Message_Upload_Image" : "Message_Upload_File",
            showCloseButton: true,
            progress: 0
        )
    }
}
