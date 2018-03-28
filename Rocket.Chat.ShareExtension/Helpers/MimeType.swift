//
//  MimeType.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/14/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

private func loadMimeTypes() -> [String: String] {
    guard let file = Bundle.main.url(forResource: "mimetype", withExtension: "json") else { return [:] }
    guard let contents = try? Data(contentsOf: file, options: []) else { return [:] }
    return (try? JSONDecoder().decode([String: String].self, from: contents)) ?? [:]
}

private var mimeTypes = loadMimeTypes()

extension URL {
    public func mimeType() -> String {
        return mimeTypes[pathExtension.lowercased()] ?? "application/octet-stream"
    }
}
