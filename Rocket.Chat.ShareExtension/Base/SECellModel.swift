//
//  SECellModel.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/2/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

protocol SECellModel {
    var reuseIdentifier: String { get }
}

extension SECellModel {
    var reuseIdentifier: String {
        return String(describing: type(of: self))
    }
}
