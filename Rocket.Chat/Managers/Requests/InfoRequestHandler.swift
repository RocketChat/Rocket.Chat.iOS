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
    var validateServerVersion = true

    func validate(with url: URL) {
        API(host: url).fetch(InfoRequest(), sessionDelegate: self, succeeded: { [weak self] result in
            self?.validateServerResponse(result: result)
        }, errored: { [weak self] _ in
            self?.delegate?.urlNotValid()
            self?.alertInvalidURL()
        })
    }

    func alertInvalidURL() {
        Alert(
            key: "alert.connection.invalid_url"
        ).present()
    }

    internal func validateServerResponse(result: InfoResult?) {
        guard let version = result?.version else {
            delegate?.urlNotValid()
            return
        }

        if validateServerVersion {
            if let minVersion = Bundle.main.object(forInfoDictionaryKey: "RC_MIN_SERVER_VERSION") as? String {
                validateServerVersion(minVersion: minVersion, version: version)
            }
        }

        delegate?.serverIsValid()
    }

    internal func validateServerVersion(minVersion: String, version: String) {
        if Semver.lt(version, minVersion) {
            Alert(
                title: localized("alert.connection.invalid_version.title"),
                message: String(format: localized("alert.connection.invalid_version.message"), version, minVersion)
            ).present()
        }
    }

}

extension InfoRequestHandler: URLSessionTaskDelegate {

    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        task.suspend()

        if let location = response.allHeaderFields["Location"] as? String {
            if let newURL = URL(string: location, scheme: "https") {
                handleRedirect(newURL)
            }
        }

        completionHandler(nil)
    }

    func handleRedirect(_ newURL: URL) {
        API(host: newURL).fetch(InfoRequest(), sessionDelegate: self, succeeded: { result in
            self.handleRedirectInfoResult(result, for: newURL)
        }, errored: { [weak self] _ in
            self?.delegate?.urlNotValid()
        })
    }

    func handleRedirectInfoResult(_ result: InfoResult, for url: URL) {
        guard
            result.raw != nil,
            let controller = self.delegate?.viewControllerToPresentAlerts,
            let newHost = url.host
        else {
            self.delegate?.urlNotValid()
            return
        }

        let alert = UIAlertController(
            title: localized("connection.server.redirect.alert.title"),
            message: String(format: localized("connection.server.redirect.alert.message"), newHost),
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: localized("global.cancel"), style: .cancel, handler: { _ in
            self.delegate?.serverChangedURL(nil)
        }))

        alert.addAction(UIAlertAction(title: localized("connection.server.redirect.alert.confirm"), style: .default, handler: { _ in
            self.delegate?.serverChangedURL(newHost)
        }))

        DispatchQueue.main.async {
            controller.present(alert, animated: true, completion: nil)
        }
    }

}
