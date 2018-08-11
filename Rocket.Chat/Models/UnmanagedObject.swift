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
    associatedtype Object: BaseModel
    var identifier: String? { get }
}

extension UnmanagedObject {
    var managedObject: Object? {
        guard let identifier = identifier else { return nil }
        return Object.find(withIdentifier: identifier)
    }
}

protocol UnmanagedConvertable {
    associatedtype UnmanagedType: UnmanagedObject
    var unmanaged: UnmanagedType { get }
}
