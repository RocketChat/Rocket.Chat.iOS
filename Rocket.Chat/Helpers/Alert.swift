//
//  Alert.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 12/8/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import MBProgressHUD

protocol Alerter: class {
    func alert(title: String, message: String, handler: ((UIAlertAction) -> Void)?)
    func alertSuccess(title: String, completion: (() -> Void)?)
    func alertYesNo(title: String, message: String, yesStyle: UIAlertAction.Style, noStyle: UIAlertAction.Style, handler: @escaping (Bool) -> Void)
}

extension UIViewController: Alerter {
    func alert(with customActions: [UIAlertAction], title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        customActions.forEach {( alert.addAction($0) )}
        present(alert, animated: true, completion: nil)
    }

    func alert(title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        present(alert, animated: true, completion: nil)
    }

    func alertYesNo(title: String, message: String, yesStyle: UIAlertAction.Style = .default, noStyle: UIAlertAction.Style = .cancel, handler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: localized("global.yes"), style: yesStyle, handler: { _ in
            handler(true)
        }))

        alert.addAction(UIAlertAction(title: localized("global.no"), style: noStyle, handler: { _ in
            handler(false)
        }))

        present(alert, animated: true, completion: nil)
    }

    func alertSuccess(title: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        let delay = DispatchTime.now() + 1.5
        DispatchQueue.main.asyncAfter(deadline: delay) {
            alert.dismiss(animated: true, completion: {() -> Void in
            })
        }
    }
}

struct Alert {
    let title: String
    let message: String
    var actions: [UIAlertAction] = []

    init(title: String, message: String) {
        self.title = title
        self.message = message
    }

    init(key: String) {
        self.init(
            title: localized("\(key).title"),
            message: localized("\(key).message")
        )
    }

    func present(handler: ((UIAlertAction) -> Void)? = nil) {
        func present() {
            let window = UIWindow.topWindow
            window.windowLevel = UIWindow.Level.alert + 1

            if actions.isEmpty {
                window.rootViewController?.alert(title: title, message: message, handler: handler)
            } else {
                window.rootViewController?.alert(with: actions, title: title, message: message)
            }
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
