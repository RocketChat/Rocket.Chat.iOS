//
//  AuthExtensions.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 15/02/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

extension Auth {

    func baseURL() -> String? {
        return self.settings?.cdnPrefixURL ?? self.settings?.siteURL
    }

}
