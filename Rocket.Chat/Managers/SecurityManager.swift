//
//  SecurityManager.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 14/02/19.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import Foundation

final class SecurityManager {

    static func save(certificate fileURL: URL, for identifier: String) -> URL? {
        let fileManager = FileManager.default

        do {
            let filename = "\(identifier).p12"
            let documentDirectory = try fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )

            let newFileURL = documentDirectory.appendingPathComponent(filename)

            let data = try Data(contentsOf: fileURL)
            try data.write(to: newFileURL)
            return newFileURL
        } catch {
            // Do nothing?!
        }

        return nil
    }

}
