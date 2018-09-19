//
//  Ask.swift
//  Rocket.Chat
//
//  Created by Luca Justin Zimmermann on 25/01/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

protocol Asker: class {
    func ask(title: String, message: String, buttons: [(title: String, handler: ((UIAlertAction) -> Void)?)], deleteOption: Int8)
}

extension UIViewController: Asker {
    func ask(title: String, message: String, buttons: [(title: String, handler: ((UIAlertAction) -> Void)?)], deleteOption: Int8 = -1) {
        let ask = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for idx in 0..<buttons.count {
            ask.addAction(UIAlertAction(
                title: buttons[idx].title,
                style: deleteOption == idx ? .destructive : .default,
                handler: buttons[idx].handler
            ))
        }
        present(ask, animated: true, completion: nil)
    }
}

struct Ask {
    let title: String
    let message: String
    let buttons: [(title: String, handler: ((UIAlertAction) -> Void)?)]
    let deleteOption: Int8

    init(title: String, message: String, buttons: [(String, ((UIAlertAction) -> Void)?)], deleteOption: Int8 = -1) {
        self.title = title
        self.message = message
        self.buttons = buttons
        self.deleteOption = deleteOption
    }

    init(key: String, buttons: [(title: String, handler: ((UIAlertAction) -> Void)?)], deleteOption: Int8 = -1) {
        self.title = NSLocalizedString("\(key).title", comment: "")
        self.message = NSLocalizedString("\(key).message", comment: "")
        self.buttons = buttons
        self.deleteOption = deleteOption
    }

    init(title: String, message: String, buttonA: String? = nil, handlerA: ((UIAlertAction) -> Void)? = nil, buttonB: String? = nil, handlerB: ((UIAlertAction) -> Void)? = nil) {
        self.init(title: title,
                  message: message,
                  buttons: [(title: buttonA ?? NSLocalizedString("global.ok", comment: ""), handler: handlerA),
                            (title: buttonB ?? NSLocalizedString("global.cancel", comment: ""), handler: handlerB)])
    }

    init(key: String, buttonA: String? = nil, handlerA: ((UIAlertAction) -> Void)? = nil, buttonB: String? = nil, handlerB: ((UIAlertAction) -> Void)? = nil) {
        self.init(title: NSLocalizedString("\(key).title", comment: ""),
                  message: NSLocalizedString("\(key).message", comment: ""),
                  buttonA: buttonA,
                  handlerA: handlerA,
                  buttonB: buttonB,
                  handlerB: handlerB)
    }

    func present() {
        func present() {
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.rootViewController = UIViewController()
            window.windowLevel = UIWindow.Level.alert + 1
            window.makeKeyAndVisible()
            window.rootViewController?.ask(title: title, message: message, buttons: buttons, deleteOption: deleteOption)
        }

        if Thread.isMainThread {
            present()
        } else {
            DispatchQueue.main.async(execute: present)
        }
    }
}
