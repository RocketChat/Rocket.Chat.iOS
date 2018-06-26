//
//  StoryboardInitializable.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 6/26/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

enum StoryboardIdentifier {
    case identifier(String)
    case initial
}

protocol StoryboardInitializable where Self: UIViewController {
    static var storyboardName: String { get }
    static var bundle: Bundle? { get }
    static var identifier: StoryboardIdentifier { get }

    static func fromStoryboard(name: String, bundle: Bundle?, identifier: StoryboardIdentifier) -> Self
}

extension StoryboardInitializable {
    static var storyboardName: String { return "Main" }
    static var bundle: Bundle? { return nil }
    static var identifier: StoryboardIdentifier { return .initial }

    static func fromStoryboard(
        name: String = Self.storyboardName,
        bundle: Bundle? = Self.bundle,
        identifier: StoryboardIdentifier = Self.identifier
        ) -> Self {
        let storyboard = UIStoryboard(name: name, bundle: nil)

        let viewController = { () -> UIViewController? in
            switch identifier {
            case .identifier(let identifier):
                return storyboard.instantiateViewController(withIdentifier: identifier)
            case .initial:
                return storyboard.instantiateInitialViewController()
            }
            }() as? Self

        guard let result = viewController else {
            fatalError("ViewController not found in '\(name)' storyboard: '\(self)'")
        }

        return result
    }
}
