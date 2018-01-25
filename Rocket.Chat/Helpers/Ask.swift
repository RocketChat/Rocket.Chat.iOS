//
//  Ask.swift
//  Rocket.Chat
//
//  Created by Luca Justin Zimmermann on 25/01/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

protocol Asker: class {
    func ask(title: String, message: String, buttons: [String], handlers: [((UIAlertAction) -> Void)?])
}

extension UIViewController: Asker {
    func ask(title: String, message: String, buttons: [String], handlers: [((UIAlertAction) -> Void)?]) {
        let ask = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if buttons.count != handlers.count {
            return
        }
        for i in 0..<buttons.count {
            ask.addAction(UIAlertAction(title: buttons[i], style: .default, handler: handlers[i]))
        }
        present(ask, animated: true, completion: nil)
    }
}

struct Ask {
    let title: String
    let message: String
    let buttons: [String]
    let handlers: [((UIAlertAction) -> Void)?]

    init(title: String, message: String, buttons: [String], handlers: [((UIAlertAction) -> Void)?]) {
        self.title = title
        self.message = message
        self.buttons = buttons
        self.handlers = handlers
    }

    init(key: String, buttons: [String], handlers: [((UIAlertAction) -> Void)?]) {
        self.title = NSLocalizedString("\(key).title", comment: "")
        self.message = NSLocalizedString("\(key).message", comment: "")
        self.buttons = buttons
        self.handlers = handlers
    }

    init(title: String, message: String, buttonA: String? = nil, handlerA: ((UIAlertAction) -> Void)? = nil, buttonB: String? = nil, handlerB: ((UIAlertAction) -> Void)? = nil) {
        self.init(title: title,
                  message: message,
                  buttons: [buttonA ?? NSLocalizedString("global.ok", comment: ""), buttonB ?? NSLocalizedString("global.cancel", comment: "")],
                  handlers: [handlerA, handlerB])
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
            window.windowLevel = UIWindowLevelAlert + 1
            window.makeKeyAndVisible()
            window.rootViewController?.ask(title: title, message: message, buttons: buttons, handlers: handlers)
        }

        if Thread.isMainThread {
            present()
        } else {
            DispatchQueue.main.async(execute: present)
        }
    }
}
