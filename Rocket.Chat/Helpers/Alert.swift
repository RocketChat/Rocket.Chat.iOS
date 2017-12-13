//
//  Alert.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 12/8/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

protocol Alerter: class {
    func alert(title: String, message: String, handler: ((UIAlertAction) -> Void)?)
}

extension UIViewController: Alerter {
    func alert(title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        present(alert, animated: true, completion: nil)
    }
}

struct Alert {
    let title: String
    let message: String

    init(key: String) {
        self.title = NSLocalizedString("\(key).title", comment: "")
        self.message = NSLocalizedString("\(key).message", comment: "")
    }

    func present() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIViewController()
        window.windowLevel = UIWindowLevelAlert + 1
        window.makeKeyAndVisible()
        window.rootViewController?.alert(title: title, message: message)
    }
}
