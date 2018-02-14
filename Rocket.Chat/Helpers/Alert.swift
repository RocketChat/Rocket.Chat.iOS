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

    init(title: String, message: String) {
        self.title = title
        self.message = message
    }

    init(key: String) {
        self.init(title: NSLocalizedString("\(key).title", comment: ""),
                  message: NSLocalizedString("\(key).message", comment: ""))
    }

    func present(handler: ((UIAlertAction) -> Void)? = nil) {
        func present() {
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.rootViewController = UIViewController()
            window.windowLevel = UIWindowLevelAlert + 1
            window.makeKeyAndVisible()
            window.rootViewController?.alert(title: title, message: message, handler: handler)
        }

        if Thread.isMainThread {
            present()
        } else {
            DispatchQueue.main.async(execute: present)
        }
    }
}

// MARK: Defaults

extension Alert {
    static var defaultError: Alert {
        return Alert(key: "error.socket.default_error")
    }
}

// MARK: Formatting
extension Alert {
    func withMessage(_ message: String? = nil, formatted args: CVarArg...) -> Alert {
        return Alert(title: title, message: String(format: message ?? self.message, args))
    }

    func withTitle(_ title: String? = nil, formatted args: CVarArg...) -> Alert {
        return Alert(title: String(format: title ?? self.title, args), message: message)
    }
}
