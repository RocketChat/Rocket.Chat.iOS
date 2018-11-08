//
//  UnmanagedObject.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 8/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import RealmSwift
import DifferenceKit

protocol UnmanagedObject: Differentiable {
    associatedtype Object: BaseModel & UnmanagedConvertible
    var managedObject: Object? { get }

    init?(_: Object)
}

protocol UnmanagedConvertible {
    associatedtype UnmanagedType: UnmanagedObject
    var unmanaged: UnmanagedType? { get }
}
