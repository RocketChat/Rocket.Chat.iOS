//
//  ChannelInfoCellProtocol.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 10/03/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

protocol ChannelInfoCellProtocol {
    associatedtype DataType

    static var identifier: String { get }
    static var defaultHeight: CGFloat { get }
    var data: DataType? { get set }
}

protocol ChannelInfoCellDataProtocol {
    associatedtype CellType

    var cellType: CellType { get }
}
