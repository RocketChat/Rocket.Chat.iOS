//
//  InfoRequestHandler.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 11/16/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import semver

protocol InfoRequestHandlerDelegate: class {
    var viewControllerToPresentAlerts: UIViewController? { get }

    func urlNotValid()
    func serverIsValid()
    func serverChangedURL(_ newURL: String?)
}

class InfoRequestHandler: NSObject {

    weak var delegate: InfoRequestHandlerDelegate?
    var url: URL?

    func validate() {
        API.shared.fetch(InfoRequest(), sessionDelegate: self) { [weak self] result in
            guard let version = result?.version else {
                self?.delegate?.serverIsValid()
                return
            }

            if let minVersion = Bundle.main.object(forInfoDictionaryKey: "RC_MIN_SERVER_VERSION") as? String {
                if Semver.lt(version, minVersion) {
                    let alert = UIAlertController(
                        title: localized("alert.connection.invalid_version.title"),
                        message: String(format: localized("alert.connection.invalid_version.message"), version, minVersion),
                        preferredStyle: .alert
                    )

                    alert.addAction(UIAlertAction(title: localized("global.ok"), style: .default, handler: nil))

                    if let controller = self?.delegate?.viewControllerToPresentAlerts {
                        controller.present(alert, animated: true, completion: nil)
                    }
                }
            }

            self?.delegate?.serverIsValid()
        }
    }

    func alertInvalidURL() {
        let alert = UIAlertController(
            title: localized("alert.connection.invalid_url.title"),
            message: localized("alert.connection.invalid_url.message"),
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: localized("global.ok"), style: .default, handler: nil))
        delegate?.viewControllerToPresentAlerts?.present(alert, animated: true, completion: nil)
    }

}

extension InfoRequestHandler: URLSessionTaskDelegate {

    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        task.suspend()

        if let location = response.allHeaderFields["Location"] as? String {
            var url = URLComponents(string: location)
            url?.scheme = "https"
            url?.query = nil

            if let newURL = url?.url {
                let newAPI = API(host: newURL)
                newAPI.fetch(InfoRequest(), sessionDelegate: self) { result in
                    guard
                        result?.error == nil,
                        let controller = self.delegate?.viewControllerToPresentAlerts,
                        let newHost = newURL.host
                    else {
                        DispatchQueue.main.async {
                            self.delegate?.urlNotValid()
                        }

                        return
                    }

                    let alert = UIAlertController(
                        title: localized("connection.server.redirect.alert.title"),
                        message: String(format: localized("connection.server.redirect.alert.message"), newHost),
                        preferredStyle: .alert
                    )

                    alert.addAction(UIAlertAction(title: localized("global.cancel"), style: .cancel, handler: { _ in
                        DispatchQueue.main.async {
                            self.delegate?.serverChangedURL(nil)
                        }
                    }))

                    alert.addAction(UIAlertAction(title: localized("connection.server.redirect.alert.confirm"), style: .default, handler: { _ in
                        DispatchQueue.main.async {
                            self.delegate?.serverChangedURL(newHost)
                        }
                    }))

                    DispatchQueue.main.async {
                        controller.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }

}
