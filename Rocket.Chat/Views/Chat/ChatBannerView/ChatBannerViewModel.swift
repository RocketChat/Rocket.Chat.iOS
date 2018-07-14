//
//  ChatBannerViewModel.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 7/5/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

struct ChatBannerViewModel {
    enum Icon: String {
        case image = "Message_Upload_Image"
        case file = "Message_Upload_File"
        case error = "Message_Upload_Error"
    }

    let text: String
    let actionText: String?
    let icon: Icon?
    let showCloseButton: Bool
    let progress: Float
}

// MARK: Empty State

extension ChatBannerViewModel {
    static var emptyState: ChatBannerViewModel {
        return ChatBannerViewModel(
            text: "Uploading layout_webapp.jpg",
            actionText: "Try again",
            icon: .error,
            showCloseButton: true,
            progress: 0
        )
    }
}

// MARK: Upload

extension ChatBannerViewModel {
    static func forUploadingFile(named name: String, type: String, failed: Bool = false) -> ChatBannerViewModel {
        return ChatBannerViewModel(
            text: String(format: localized("chat.banner.upload.\(failed ? "error" : "uploading")"), name),
            actionText: failed ? localized("chat.banner.upload.retry") : nil,
            icon: failed ? .error : (type.contains("image") || type.contains("video") ? .image : .file),
            showCloseButton: true,
            progress: 0
        )
    }
}
