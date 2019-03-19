//
//  IntExtensions.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 19/03/19.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import Foundation

extension Int {

    func humanized() -> String {
        if self > 999999 {
            return String.localizedStringWithFormat("%.2fM", Float(self) / 1000000)
        } else if self > 9999 {
            return String.localizedStringWithFormat("%.1fk", Float(self) / 1000)
        }

        return String.localizedStringWithFormat("%d", self)
    }

}
