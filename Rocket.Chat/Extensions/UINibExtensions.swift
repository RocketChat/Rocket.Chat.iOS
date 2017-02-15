//
//  UINibExtensions.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 15/02/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

extension UINib {

    func instantiate() -> Any? {
        return self.instantiate(withOwner: nil, options: nil).first
    }

}
